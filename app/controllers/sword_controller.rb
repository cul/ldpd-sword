require 'sword/util.rb'
require 'sword/endpoints/academic_commons_endpoint.rb'
require 'sword/endpoints/eprints_endpoint.rb'
require 'sword/endpoints/proquest_endpoint.rb'

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
    @endpoint = get_endpoint(@collection_slug,
                             @depositor_user_id)
    @path_to_deposit_contents = Sword::Util::unzip_deposit_file request

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Received deposit POST. Collection slug: #{@collection_slug}, " \
                      "Username: #{@depositor_user_id}, " \
                      "Path to contents: #{@path_to_deposit_contents}"
                     )

    @endpoint.handle_deposit(@path_to_deposit_contents)

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Title: #{@endpoint.deposit_title.truncate_words(10)}, " \
                      "Files: #{@endpoint.documents_to_deposit}, " \
                      "Hyacinth item pid: #{@endpoint.adapter_item_identifier}, " \
                      "Hyacinth asset pids: #{@endpoint.asset_pids}, " \
                      "Path to SWORD contents: #{@path_to_deposit_contents}"
                     )

    # create Deposit instance to store deposit info in database
    @deposit = Deposit.new
    @deposit.depositor_user_id = @depositor_user_id
    @deposit.collection_slug = @collection_slug
    @deposit.deposit_files = @endpoint.documents_to_deposit
    # fcd1, 9/6/18: use truncate_words here, but should also add a
    # truncate(200, omission: '') at the model level to make sure we
    # don't go beyond the 255 char limit for a string in MySql
    # For now, just tack it on here.
    @deposit.title =
      @endpoint.deposit_title.truncate_words(20).truncate(200, omission: '')
    @deposit.item_in_hyacinth = @endpoint.adapter_item_identifier
    @deposit.asset_pids = @endpoint.asset_pids
    @deposit.ingest_confirmed = @endpoint.confirm_ingest
    @deposit.content_path = @path_to_deposit_contents
    @deposit.save
    # @depositor.deposits << @deposit
    # @collection.deposits << @deposit
    response.status = 201
    render json: { item_pid: @endpoint.adapter_item_identifier,
                   ingest_into_hyacinth: !(HYACINTH_CONFIG[:bypass_ingest] or COLLECTIONS[:slug][@endpoint.collection_slug][:bypass_hyacinth_ingest])}
  end

  def resubmit_deposit(deposit)

    @endpoint = get_endpoint(deposit.collection_slug,
                             deposit.depositor_user_id)

    @path_to_deposit_contents = deposit.content_path

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("About to resubmit deposit for deposit id: #{deposit.id}:" \
                      "Collection slug: #{deposit.collection_slug}, " \
                      "Username: #{deposit.depositor_user_id}, " \
                      "Path to contents: #{@path_to_deposit_contents}"
                     )

    @endpoint.handle_deposit(@path_to_deposit_contents)

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Following is a re-deposit:" \
                      "Title: #{@endpoint.deposit_title.truncate_words(10)}, " \
                      "Files: #{@endpoint.documents_to_deposit}, " \
                      "Hyacinth item pid: #{@endpoint.adapter_item_identifier}, " \
                      "Hyacinth asset pids: #{@endpoint.asset_pids}, " \
                      "Path to SWORD contents: #{@path_to_deposit_contents}"
                     )

    # create Deposit instance to store deposit info in database
    @deposit = Deposit.new
    @deposit.depositor_user_id = @depositor_user_id
    @deposit.collection_slug = @collection_slug
    @deposit.deposit_files = @endpoint.documents_to_deposit
    @deposit.title = "(RE-DEPOSIT) " + deposit.title
    @deposit.item_in_hyacinth = @endpoint.adapter_item_identifier
    @deposit.asset_pids = @endpoint.asset_pids
    @deposit.ingest_confirmed = @endpoint.confirm_ingest
    @deposit.content_path = @path_to_deposit_contents
    @deposit.save
    response.status = 201
    render json: { item_pid: @endpoint.adapter_item_identifier,
                   ingest_into_hyacinth: !(HYACINTH_CONFIG[:bypass_ingest] or COLLECTIONS[:slug][@endpoint.collection_slug][:bypass_hyacinth_ingest])}
  end

  def service_document
    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Received Service Document request. Username: #{@depositor_user_id}")

    content = HashWithIndifferentAccess.new
    # For site-specific values, read from the config file:
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    content[:http_host] = request.env["HTTP_HOST"]
    content[:collections] = []
    COLLECTIONS[:slug].keys.each do |collection_slug|
      if COLLECTIONS[:slug][collection_slug][:depositors].include? @depositor_user_id
        content[:collections] << collection_info_for_service_document(collection_slug)
      end
    end
    # @depositor.collections.each { |collection| content[:collections] << collection.info_for_service_document }
    render xml: view_context.service_document_xml(content)
  end

  private

    def collection_info_for_service_document(collection_slug)
      info = HashWithIndifferentAccess.new
      info[:atom_title] = COLLECTIONS[:slug][collection_slug][:atom_title]
      info[:slug] = collection_slug
      info[:mime_types] = nil
      info[:sword_package_types] = nil
      info[:abstract] = nil
      info[:mediation_enabled] = false
      info
    end

    def get_endpoint(collection_slug,
                     depositor_user_id)
      case COLLECTIONS[:slug][collection_slug][:parser]
      when "academic-commons"
        Sword::Endpoints::AcademicCommonsEndpoint.new(collection_slug, depositor_user_id)
      when "proquest"
        Sword::Endpoints::ProquestEndpoint.new(collection_slug, depositor_user_id)
      when "eprints"
        Sword::Endpoints::EprintsEndpoint.new(collection_slug, depositor_user_id)
      else
        # raise an exception here
      end
    end

    def check_for_valid_collection_slug
      check_for_valid_collection_slug_using_config
    end

    def check_for_valid_collection_slug_using_config
      @collection_slug = params[:collection_slug]
      unless COLLECTIONS[:slug].key? @collection_slug
        Rails.logger.warn "Invalid collection slug (#{@collection_slug})! Supplied URL: #{request.url}"
        head :bad_request
      end
    end

    def check_for_valid_collection_slug_using_db
      @collection = Collection.find_by slug: params[:collection_slug]
      if @collection.nil?
        Rails.logger.warn "Invalid collection slug (#{params[:collection_slug]})! Supplied URL: #{request.url}"
        head :bad_request 
      end
    end

    def check_basic_http_authentication
      check_basic_http_authentication_using_config
    end

    def check_basic_http_authentication_using_config
      result = false
      @depositor_user_id, @password = pull_credentials
      unless DEPOSITORS[:basic_authentication_user_ids].key?(@depositor_user_id)
        warn_msg_reason = "Unknown user/depositor: #{@depositor_user_id}"
        # Rails.logger.warn "Unknown user/depositor: #{@depositor_user_id}"
      else
        if DEPOSITORS[:basic_authentication_user_ids][@depositor_user_id][:basic_authentication_password].eql? @password
          result = true
        else
          warn_msg_reason = "Bad password for following user/depositor: #{@depositor_user_id}"
        end
      end
      unless result
        Rails.logger.warn "Authentication failure -- #{warn_msg_reason}"
        head 511
      end
    end

    def check_basic_http_authentication_using_db
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
      check_depositor_collection_permission_using_config
    end

    def check_depositor_collection_permission_using_config
      unless COLLECTIONS[:slug][@collection_slug][:depositors].include? @depositor_user_id
        Rails.logger.warn "user/depositor #{@depositor_user_id} does not have access to collection slug #{@collection_slug}"
        head :bad_request
      end
    end

    def check_depositor_collection_permission_using_db
      # fcd1, 08/09/16: Change behavior if needed. Check standard/existing code
      unless @depositor.collections.include? @collection
        Rails.logger.warn "user/depositor #{@user_id} does not have access to collection #{@collection}"
        head :bad_request
      end
    end
end
