class SwordController < ApplicationController
  before_action :check_for_valid_collection_slug, only: [:deposit]
  before_action :check_basic_http_authentication, only: [:deposit, :service_document]
  before_action :check_depositor_collection_permission, only: [:deposit]

  def deposit
    # here, take a look at the slug and decide which Endpoint instance to call
    # a few ways to do it: have an entry for each collection active record
    # stating which endpoint instance to create
    # another way to store the info is in the config file instead of the database
    # use @collection.parser, which will need to be changed to
    # @collection.endpoint, i.e. will need to change attribute in
    # collection model from parser to endpoint
    @endpoint = Sword::Endpoints::Endpoint::get_endpoint(@collection,
                                                         @depositor)
    @path_to_deposit_contents = Sword::Util::unzip_deposit_file request

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Received deposit POST. Collection slug: #{@collection.slug}, " \
                      "Username: #{@depositor.basic_authentication_user_id}, " \
                      "Path to contents: #{@path_to_deposit_contents}"
                     )

    @endpoint.handle_deposit(@path_to_deposit_contents)

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Title: #{@endpoint.deposit_title.truncate_words(10)}, " \
                      "Files: #{@endpoint.documents_to_deposit}, " \
                      "Hyacinth item pid: #{@endpoint.adapter_item_identifier}"
                     )

    # create Deposit instance to store deposit info in database
    @deposit = Deposit.new
    @deposit.deposit_files = @endpoint.documents_to_deposit
    @deposit.title = @endpoint.deposit_title
    @deposit.item_in_hyacinth = @endpoint.adapter_item_identifier
    @depositor.deposits << @deposit
    @collection.deposits << @deposit
    response.status = 201
    render json: { item_pid: @endpoint.adapter_item_identifier }
  end

  def service_document
    content = HashWithIndifferentAccess.new
    # For site-specific values, read from the config file:
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    content[:http_host] = request.env["HTTP_HOST"]
    content[:collections] = []
    @depositor.collections.each { |collection| content[:collections] << collection.info_for_service_document }
    render xml: view_context.service_document_xml(content)
  end

  private
    def check_for_valid_collection_slug
      @collection = Collection.find_by slug: params[:collection_slug]
      if @collection.nil?
        Rails.logger.warn "Invalid collection slug (#{params[:collection_slug]})! Supplied URL: #{request.url}"
        head :bad_request 
      end
    end

    def check_basic_http_authentication
      result = false
      # @user_id, @password = Sword::DepositRequest.pullCredentials(request)
      @user_id, @password = pull_credentials
      @depositor = Depositor.find_by(basic_authentication_user_id: @user_id)
      if @depositor.nil?
        warn_msg_reason = "Unknown user/depositor: #{@user_id}"
        # Rails.logger.warn "Unknown user/depositor: #{@user_id}"
      else 
        warn_msg_reason = "Bad password for following user/depositor: #{@user_id}"
        result = @depositor.authenticate(@password)
      end
      unless result
        Rails.logger.warn "Authentication failure -- #{warn_msg_reason}"
        head 511
      end
    end

    # following is cut-and-paste of all the code in
    # DepositRequest::pullCredentials
    def pull_credentials
      authorization = String.new(request.headers["Authorization"].to_s)
      if(authorization.include? 'Basic ')
        authorization['Basic '] = ''
        authorization = Base64.decode64(authorization)
        credentials = authorization.split(":")
        [credentials[0] , credentials[1]]
      end
    end
    
    def check_depositor_collection_permission
      # fcd1, 08/09/16: Change behavior if needed. Check standard/existing code
      unless @depositor.collections.include? @collection
        Rails.logger.warn "user/depositor #{@user_id} does not have access to collection #{@collection}"
        head :bad_request
      end
    end
end
