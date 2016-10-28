require "sword/deposit_request"
require 'sword/deposit_utils'
require 'sword/composers/hyacinth_composer'
require 'sword/ingest/hyacinth_ingest'

class SwordController < ApplicationController
  before_action :check_for_valid_collection_slug, only: [:deposit]
  before_action :check_basic_http_authentication, only: [:deposit, :service_document]
  before_action :check_depositor_collection_permission, only: [:deposit]

  def deposit
    # at this, with all the before_action filters, the following instance variables are set:
    # @collection, @depositor
    @deposit_request = Sword::DepositRequest.new(request, @collection.slug)

    @zip_file_path = Sword::DepositUtils.process_package_file(@deposit_request.content, @deposit_request.file_name)
                                  
    @parser = Sword::DepositUtils.getParser @collection.parser

    @deposit_content = @parser.parse(File.join(@zip_file_path, SWORD_CONFIG[:contents_zipfile_subdir]),
                                     File.join(@zip_file_path, @deposit_request.file_name))

    # compose hyacinth data
    @hyacinth_composer = Sword::Composers::HyacinthComposer.new(@deposit_content,
                                                                @collection.hyacinth_project_string_key)
    @json_for_hyacinth_item = @hyacinth_composer.compose_json_item

    @hyacinth_ingest = Sword::Ingest::HyacinthIngest.new
    @hyacinth_response = @hyacinth_ingest.ingest_json @json_for_hyacinth_item

    # need to add a check here for 200 response
    # @hyacinth_pid = JSON.parse(@hyacinth_response.body)['pid']
    @hyacinth_pid = @hyacinth_response.pid if @hyacinth_response.success?
    Rails.logger.info "response body from Hyacinth is: " +  @hyacinth_response.body
    Rails.logger.info "pid from Hyacinth is: " +  @hyacinth_pid.inspect

    files = Sword::DepositUtils.getAllFilesList(File.join(@zip_file_path,SWORD_CONFIG[:contents_zipfile_subdir]))

    Sword::DepositUtils.cp_files_to_hyacinth_upload_dir(@zip_file_path,
                                                        files)

    files.each do |file|
      @json_for_hyacinth_asset = @hyacinth_composer.compose_json_asset(file, @hyacinth_pid)
      @hyacinth_response = @hyacinth_ingest.ingest_json @json_for_hyacinth_asset
      Rails.logger.info "response code from Hyacinth is: " +  @hyacinth_response.code
      Rails.logger.info "response body from Hyacinth is: " +  @hyacinth_response.body
    end
    
    @deposit = Deposit.new
    @deposit.title = @deposit_content.title
    @deposit.abstract = @deposit_content.abstract
    @deposit.item_in_hyacinth = @hyacinth_pid
    @depositor.deposits << @deposit
    @collection.deposits << @deposit
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
end
