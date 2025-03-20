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
    @endpoint = Sword::Endpoints::Endpoint.get_endpoint(@collection_slug,
                                                        @depositor_user_id)
    request_body = request.body
    @path_to_deposit_contents = Sword::Util::unzip_deposit_file request_body

    log_received_deposit_post(@collection_slug,
                              @depositor_user_id,
                              @path_to_deposit_contents)

    @endpoint.handle_deposit(@path_to_deposit_contents)

    log_deposit_result_info(@endpoint.deposit_title,
                            @endpoint.documents_to_deposit,
                            @endpoint.adapter_item_identifier,
                            @endpoint.asset_pids,
                            @path_to_deposit_contents)

    # create Deposit instance and store deposit info in database
    @deposit = create_deposit(@depositor_user_id,
                              @collection_slug,
                              @endpoint.documents_to_deposit,
                              @endpoint.deposit_title,
                              @endpoint.adapter_item_identifier,
                              @endpoint.asset_pids,
                              @endpoint.confirm_ingest,
                              @path_to_deposit_contents)
    response.status = 201
    render json: { item_pid: @endpoint.adapter_item_identifier,
                   ingest_into_hyacinth: !(HYACINTH_CONFIG[:bypass_ingest] or COLLECTIONS[:slug][@endpoint.collection_slug][:bypass_hyacinth_ingest])}
  end

  def service_document
    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Received Service Document request. Username: #{@depositor_user_id}")
    content = helpers.service_document_content
    render xml: view_context.service_document_xml(content)
  end

  def log_received_deposit_post(collection_slug,
                                depositor_user_id,
                                path_to_deposit_contents)
    Rails.logger.warn("Received deposit POST. Collection slug: #{collection_slug}, " \
                      "Username: #{depositor_user_id}, " \
                      "Path to contents: #{path_to_deposit_contents}")
  end

  def log_deposit_result_info(title,
                              files,
                              item_pid,
                              asset_pids,
                              path_content)
    Rails.logger.warn("Title: #{title.truncate_words(10)}, " \
                      "Files: #{files}, " \
                      "Hyacinth item pid: #{item_pid}, " \
                      "Hyacinth asset pids: #{asset_pids}, " \
                      "Path to SWORD contents: #{path_content}"
                     )
  end

  def create_deposit(depositor_user_id,
                     collection_slug,
                     documents_to_deposit,
                     deposit_title,
                     adapter_item_identifier,
                     asset_pids,
                     confirm_ingest,
                     path_to_deposit_contents)
    helpers.create_deposit(depositor_user_id,
                           collection_slug,
                           documents_to_deposit,
                           deposit_title,
                           adapter_item_identifier,
                           asset_pids,
                           confirm_ingest,
                           path_to_deposit_contents)
  end

  private

    def check_for_valid_collection_slug
      @collection_slug = params[:collection_slug]
      unless COLLECTIONS[:slug].key? @collection_slug
        Rails.logger.warn "Invalid collection slug (#{@collection_slug})! Supplied URL: #{request.url}"
        head :bad_request
      end
    end

    def check_basic_http_authentication
      result = false
      @depositor_user_id, @password = helpers.pull_credentials(request)
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

    def check_depositor_collection_permission
      unless COLLECTIONS[:slug][@collection_slug][:depositors].include? @depositor_user_id
        Rails.logger.warn "user/depositor #{@depositor_user_id} does not have access to collection slug #{@collection_slug}"
        head :bad_request
      end
    end
end
