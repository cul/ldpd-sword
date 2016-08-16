require "sword/deposit_request"

class SwordController < ApplicationController
  before_action :check_for_valid_collection_slug, only: [:deposit]
  before_action :check_basic_http_authentication, only: [:deposit]
  before_action :check_depositor_collection_permission, only: [:deposit]
  # fcd1, 08/16/16: following sets up a hard coded Depositor, for testing
  before_action :setup_depositor_for_testing_service_document, only: [:service_document]

  def deposit
    # puts request.inspect if Rails.env.development? or Rails.env.test?
    # puts Sword::DepositRequest.new(request, @collection.slug).inspect
  end

  def service_document
    content = HashWithIndifferentAccess.new
    # For site-specific values, read from the config file:
    content[:sword_version] = SWORD_CONFIG[:service_document][:sword_version]
    content[:sword_verbose] = SWORD_CONFIG[:service_document][:sword_verbose]
    content[:collections] = []
    @depositor.collections.each { |collection| content[:collections] << collection.info_for_service_document }
    # content[:collections] = depositor.collections.to_a
    content['atom_title'] = 'Test Title'
    content['dcterms_abstract'] = 'Test DC Terms abstract'
    content['sword_content_types_supported'] = ['http://support-test-package-one', 'http://support-test-package-two']
    content['sword_packaging_accepted'] = ['application/zip']
    content['sword_mediation'] = 'false'
    puts view_context.service_document_xml content, request.env["HTTP_HOST"]
    render xml: view_context.service_document_xml(content, request.env["HTTP_HOST"])

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
      result = (@depositor.basic_authentication_password == @password) unless @depositor.nil?
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

