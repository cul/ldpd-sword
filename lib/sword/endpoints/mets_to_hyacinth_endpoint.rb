# frozen_string_literal: true

class Sword::Endpoints::MetsToHyacinthEndpoint < Sword::Endpoints::Endpoint
  def initialize(collection_slug, depositor_user_id)
    super
    @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
    # @mets_file
  end

  def set_hyacinth_project_and_deposited_by
    # populate metadata for hyacinth item object and ingest it into hyacinth
    @hyacinth_adapter.hyacinth_project =
      COLLECTIONS[:slug][@collection_slug][:hyacinth_project_string_key]
    @hyacinth_adapter.deposited_by =
      DEPOSITORS[:basic_authentication_user_ids][@depositor_user_id][:name]
  end

  def log_rails_error_and_raise
    Rails.logger.error('Hyacinth request unsuccessful: ' \
                       "hyacinth_response: #{@ingest_item_response.inspect}, " \
                       "hyacinth_response.body: #{@ingest_item_response.body.inspect}")
    raise 'Hyacinth request was not successful, please see log'
  end

  def ingest_item_into_hyacinth
    set_hyacinth_project_and_deposited_by
    @hyacinth_adapter.compose_internal_format_item
    @hyacinth_adapter.ingest_item
    if @hyacinth_adapter.last_ingest_successful?
      @pid_hyacinth_item_object = @hyacinth_adapter.pid_last_ingest
    else
      log_rails_error_and_raise unless @hyacinth_adapter.no_op_post
    end
  end

  # for each deposited document, ingest into hyacinth as child asset of above item
  def ingest_documents_into_hyacinth
    @documents_to_deposit.each do |document_filename|
      document_filepath = File.join(@content_dir, document_filename)
      @hyacinth_adapter.ingest_asset(@pid_hyacinth_item_object, document_filepath)
    end
  end

  def ingest_mets_xml_file_into_hyacinth(mets_filename = 'mets.xml')
    mets_xml_filepath = File.join(@content_dir, mets_filename)
    @hyacinth_adapter.ingest_asset(@pid_hyacinth_item_object, mets_xml_filepath)
  end

  def ingest_into_hyacinth
    # unless HYACINTH_CONFIG[:bypass_ingest] or COLLECTIONS[:slug][@collection_slug][:bypass_hyacinth_ingest]
    if HYACINTH_CONFIG[:bypass_ingest] || COLLECTIONS[:slug][@collection_slug][:bypass_hyacinth_ingest]
      Rails.logger.warn 'Bypassing ingest into Hyacinth, set bogus PID'
      # bogus item identifier. Instead, could use string 'NotApplicable'
      @adapter_item_identifier = 'na:xxxxxxxxxxx'
    else
      # @adapter_item_identifier stores the parent pid returned
      # from Hyacinth
      @adapter_item_identifier = ingest_item_into_hyacinth
      ingest_documents_into_hyacinth
      ingest_mets_xml_file_into_hyacinth
    end
  end

  def handle_deposit(path_to_contents)
    @content_dir = path_to_contents
    # check existence of mets.xml file
    raise 'mets.xml file missing' unless File.exist?(File.join(@content_dir, 'mets.xml'))

    @mets_xml_file = File.join(@content_dir, 'mets.xml')
    @mets_parser.parse @mets_xml_file
    @documents_to_deposit = @mets_parser.flocat_xlink_href
  end
end
