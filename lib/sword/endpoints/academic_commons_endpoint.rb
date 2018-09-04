module Sword
  module Endpoints
    class AcademicCommonsEndpoint < MetsToHyacinthEndpoint

      attr_reader :mods_parser,
                  :hyacinth_adapter

      def initialize(collection, depositor)
        super
        @mods_parser = Sword::Parsers::ModsParser.new
      end

      def handle_deposit(path_to_contents)
        # handle_deposit from parent class will process the mets portion of the mets.xml file
        super

        # read mods from mets.xml file and process metadata
        @mods_parser.parse @mets_parser.xmlData_as_nokogiri_xml_element.first
        process_metadata

        # @adapter_item_identifier stores the parent pid returned
        # from Hyacinth
        @adapter_item_identifier = ingest_item_into_hyacinth

        ingest_documents_into_hyacinth
        ingest_mets_xml_file_into_hyacinth
      end

      # This method takes the parsed metadata and maps it to the associated
      # field in HyacinthIngest object
      def process_metadata
        @hyacinth_adapter.abstract = @mods_parser.abstract
        @hyacinth_adapter.date_issued_start = @mods_parser.date_issued_start
        unless @mods_parser.identifier_doi.nil?
          @hyacinth_adapter.parent_publication = Sword::Metadata::ParentPublication.new
          @hyacinth_adapter.parent_publication.doi = @mods_parser.identifier_doi
        end
        @hyacinth_adapter.license_uri =
          @mods_parser.access_condition_use_and_reproduction_license_uri
        @hyacinth_adapter.note_type = 'internal'
        @hyacinth_adapter.note_value = @mods_parser.note_internal
        process_name_metadata
        @hyacinth_adapter.title = @mods_parser.title
        @hyacinth_adapter.uri = @mods_parser.identifier_uri
        @hyacinth_adapter.use_and_reproduction_uri =
          @mods_parser.access_condition_use_and_reproduction_rights_status_uri
        @deposit_title = @mods_parser.title
      end

      def process_name_metadata
        @mods_parser.names.each do |mods_name|
          case mods_name.type
          when 'personal'
            individual = Sword::Metadata::PersonalName.new
            individual.role = 'author'
            # The <namePart> content from AC will always be in the
            # following format: 'Last, First M.'
            individual.full_name_naf_format = mods_name.name_part
            individual.uni = mods_name.id
            @hyacinth_adapter.personal_names << individual
          else
            raise 'AC should only be sending personal names'
          end
        end
      end
    end
  end
end
