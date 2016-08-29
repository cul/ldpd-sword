require "sword/deposit_request"
require 'sword/deposit_utils'
require 'sword/composers/hyacinth_composer'
require 'sword/ingest/hyacinth_ingest'

class SwordController < ApplicationController
  before_action :check_for_valid_collection_slug, only: [:deposit]
  before_action :check_basic_http_authentication, only: [:deposit]
  before_action :check_depositor_collection_permission, only: [:deposit]
  # fcd1, 08/16/16: following sets up a hard coded Depositor, for testing
  before_action :setup_depositor_for_testing_service_document, only: [:service_document]

  def deposit
    # at this, with all the before_action filters, the following instance variables are set:
    # @collection, @depositor
    # puts @collection.inspect
    # puts request.inspect if Rails.env.development? or Rails.env.test?
    # puts request.env.inspect if Rails.env.development? or Rails.env.test?
    # puts request.headers.inspect if Rails.env.development? or Rails.env.test?
    # puts request.headers["SERVER_PORT"] if Rails.env.development? or Rails.env.test?
    # puts request.headers["X-On-Behalf-Of"] if Rails.env.development? or Rails.env.test?
    # file = request.body.read if Rails.env.development? or Rails.env.test?
    # puts file.inspect
    @deposit_request = Sword::DepositRequest.new(request, @collection.slug)

    # @zip_dir = SWORD_CONFIG[:unzip_dir]
    # Sword::DepositUtils.save_file(@deposit_request.content, @deposit_request.file_name, @zip_dir)
    # Sword::DepositUtils.unpackZip("#{@zip_dir}/#{@deposit_request.file_name}", @zip_dir)
    # fcd1, 08/21/16: above 3 lines of code replaced with the following single line:
    @zip_file_path = Sword::DepositUtils.process_package_file(@deposit_request.content, @deposit_request.file_name)
    # puts "!!!!!!!!!!!!!!!!!!!! ZIP_FILE_PATH !!!!!!!!!!!!!!!!!!!"
    # puts @zip_file_path
                                  
    @parser = Sword::DepositUtils.getParser @collection.parser
    # puts @collection.hyacinth_project_string_key
    # puts @parser.inspect
    # raise
    # @deposit_content = Sword::DepositContent.new
    # @parser.new_parse_content(@deposit_content, File.join(@zip_file_path, SWORD_CONFIG[:contents_zipfile_subdir]))
    @deposit_content = @parser.parse(File.join(@zip_file_path, SWORD_CONFIG[:contents_zipfile_subdir]),
                                     File.join(@zip_file_path, @deposit_request.file_name))

    # puts @deposit_content.inspect
    # raise

    # compose hyacinth data
    @hyacinth_composer = Sword::Composers::HyacinthComposer.new(@deposit_content,
                                                                @collection.hyacinth_project_string_key)
    @json_for_hyacinth_item = @hyacinth_composer.compose_json_item

    # puts "!!!!!!!!!!!!!!!!!!!! Hyacinth JSON !!!!!!!!!!!!!!!!!!!"
    # puts @json_for_hyacinth_item

    @hyacinth_ingest = Sword::Ingest::HyacinthIngest.new
    @hyacinth_response = @hyacinth_ingest.ingest_json @json_for_hyacinth_item if Rails.env.development?
    # puts @hyacinth_response.inspect if Rails.env.development?
    # puts @hyacinth_response.body if Rails.env.development?

    # need to add a check here for 200 response
    @hyacinth_pid = JSON.parse(@hyacinth_response.body)['pid'] if Rails.env.development?
    # puts "!!!!!!! Hyacinth pid !!!!: #{@hyacinth_pid}" if Rails.env.development?

    # puts "!!!!!!!!!!!!!!!!!!!!!!!!!self.getAllFilesList!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    files = Sword::DepositUtils.getAllFilesList(File.join(@zip_file_path,SWORD_CONFIG[:contents_zipfile_subdir]))

    Sword::DepositUtils.cp_files_to_hyacinth_upload_dir(@zip_file_path,
                                                        files)

    files.each do |file|
      @json_for_hyacinth_asset = @hyacinth_composer.compose_json_asset(file, @hyacinth_pid)
      @hyacinth_response = @hyacinth_ingest.ingest_json @json_for_hyacinth_asset if Rails.env.development?
    end
    
    @deposit = Deposit.new
    @deposit.title = @deposit_content.title
    @deposit.item_in_hyacinth = @hyacinth_pid
    @depositor.deposits << @deposit
    @collection.deposits << @deposit

    # puts @deposit_request.inspect
    # puts @deposit_request.content.class

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
    # puts view_context.service_document_xml(@depositor, request.env["HTTP_HOST"])
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
      # puts "Called setup_depositor_for_testing_service_document"
      @depositor = Depositor.find_by(id: 1)
      # puts @depositor.inspect
    end
end
