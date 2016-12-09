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
                                                                @collection.hyacinth_project_string_key,
                                                                @depositor.name)
    @json_for_hyacinth_item = @hyacinth_composer.compose_json_item
    @hyacinth_ingest = Sword::Ingest::HyacinthIngest.new
    @hyacinth_response = @hyacinth_ingest.ingest_json @json_for_hyacinth_item
    @hyacinth_pid = @hyacinth_response.pid if @hyacinth_response.success?

    # fcd1, 12/09/16: Initially, log both success and failure.
    # later, when prod has been up for a while, maybe can get stop logging
    # success, and instead just log the failures
    if @hyacinth_response.success?
      Rails.logger.info "Hyacinth request was successful"
      Rails.logger.info "Inspect hyacinth_response: #{@hyacinth_response.inspect}"
      Rails.logger.info "Inspect hyacinth_response.body: #{@hyacinth_response.body.inspect}"
    else
      Rails.logger.info "Hyacinth request was not successful"
      Rails.logger.info "Inspect hyacinth_response: #{@hyacinth_response.inspect}"
      Rails.logger.info "Inspect hyacinth_response.body: #{@hyacinth_response.body.inspect}"
    end

    files = Sword::DepositUtils.getAllFilesList(File.join(@zip_file_path,SWORD_CONFIG[:contents_zipfile_subdir]))
    @temp_subdir_in_hyacinth_upload_dir = File.join('SWORD',"tmp_#{Process.pid}#{Time.now.to_i}")
    Rails.logger.info("#{__FILE__},#{__LINE__}:")
    Rails.logger.info "Inspect @temp_subdir_in_hyacinth_upload_dir: #{@temp_subdir_in_hyacinth_upload_dir}"
    Rails.logger.info "Inspect @zip_file_path: #{@zip_file_path}"
    Sword::DepositUtils.cp_files_to_hyacinth_upload_dir(@zip_file_path,
                                                        @temp_subdir_in_hyacinth_upload_dir,
                                                        files)

    files.each do |file|
      @json_for_hyacinth_asset = @hyacinth_composer.compose_json_asset(file, @hyacinth_pid)
      @hyacinth_response = @hyacinth_ingest.ingest_json @json_for_hyacinth_asset
    end
    
    # fcd1, 12/07/16: Remove files and tmp dir from hyacinth upload directory.
    # Sword::DepositUtils.removeHyacinthFilesAndSubir(@temp_subdir_in_hyacinth_upload_dir, files)

    @deposit = Deposit.new
    @deposit.deposit_files = files
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
    render xml: view_context.service_document_xml(content)
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
end
