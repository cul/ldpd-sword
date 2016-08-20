require "sword/deposit_request"

class SwordController < ApplicationController
  before_action :check_for_valid_collection_slug, only: [:deposit]
  before_action :check_basic_http_authentication, only: [:deposit]
  before_action :check_depositor_collection_permission, only: [:deposit]
  # fcd1, 08/16/16: following sets up a hard coded Depositor, for testing
  before_action :setup_depositor_for_testing_service_document, only: [:service_document]

  def deposit
    # puts request.inspect if Rails.env.development? or Rails.env.test?
    # puts request.env.inspect if Rails.env.development? or Rails.env.test?
    # puts request.headers.inspect if Rails.env.development? or Rails.env.test?
    # puts request.headers["SERVER_PORT"] if Rails.env.development? or Rails.env.test?
    # puts request.headers["X-On-Behalf-Of"] if Rails.env.development? or Rails.env.test?
    # file = request.body.read if Rails.env.development? or Rails.env.test?
    # puts file.inspect
    @deposit_request = Sword::DepositRequest.new(request, @collection.slug)
    # puts @deposit_request.inspect
    # puts @deposit_request.content.class

    # at this, with all the before_action filters, we have the following invariant conditions:
    # collection slug in URL was valid, and @collection is set
    # authentication has passed, and @depositor is set

    # Get info out of the reqest: 
    
    # retrieve the hyacinth project. Need a try exception statement around the following line
    # also, can get if instance variable and use func return straight.
    # puts @hyacinth_project.inspect
  end

  def service_document
    content = HashWithIndifferentAccess.new
    # For site-specific values, read from the config file:
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    
    content[:http_host] = request.env["HTTP_HOST"]

    content[:collections] = []
    @depositor.collections.each { |collection| content[:collections] << collection.info_for_service_document }
    # content[:collections] = depositor.collections.to_a
    # puts view_context.service_document_xml content, request.env["HTTP_HOST"]
    render xml: view_context.service_document_xml(content)

  end

  # replace the above method with this one once the following has been done:
  # the needed attributes have been added to the collection model.
  # also, if needed (not sure), add needed attributes to the depositor model
  # finally, need to create the has_and_belongs_to_many relationship.
  def service_document_new
    puts view_context.service_document_xml(@depositor, request.env["HTTP_HOST"])
    render xml: view_context.service_document_xml(@depositor, request.env["HTTP_HOST"])
  end

  private
    def check_for_valid_collection_slug
      @collection = Collection.find_by slug: params[:collection_slug]
      # may want to do redirect_to or render something instead. For now, do this
      head :bad_request if (@collection.nil?)
    end

    def check_basic_http_authentication
      result = false
      @user_id, @password = Sword::DepositRequest.pullCredentials(request)
      @depositor = Depositor.find_by(basic_authentication_user_id: @user_id)
      result = @depositor.authenticate(@password) unless @depositor.nil?
      head 511 unless result
    end
    
    def check_depositor_collection_permission
      # fcd1, 08/09/16: Change behavior if needed. Check standard/existing code
      head :bad_request unless @depositor.collections.include? @collection
    end

    def collection_content_for_service_document
      # depositor = @depositor
      # fcd1, 08/15/16: For now, enter Depositor by hand in code. Later, use above set by before_action
      # depositor = Depositor.find_by(id: 1)
      # content = []
      # depositor.
    end

    def setup_depositor_for_testing_service_document
      puts "Called setup_depositor_for_testing_service_document"
      @depositor = Depositor.find_by(id: 1)
      puts @depositor.inspect
    end
end
