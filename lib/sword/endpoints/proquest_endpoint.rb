module Sword
  module Endpoints
    class ProquestEndpoint < MetsToHyacinthEndpoint
      attr_reader :proquest_etd_parser,
                  :hyacinth_adapter

      def initialize(collection, depositor)
        super
        @proquest_etd_parser = Sword::Parsers::ProquestEtdParser.new
      end

      def handle_deposit(path_to_contents)
        super

        # parse proquest ETD metadata from mets.xml file. Note that in a
        # proquest deposit, there are two xmlData elements, and the second one
        # contains the proquest ETD metadata
        @proquest_etd_parser.parse @mets_parser.xmlData_as_nokogiri_xml_element.second

        # process parsed metadata
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
        # set hyacinth fields for the "hard-coded" metadata
        @hyacinth_adapter.genre_value = Sword::Constants::GENRE_TERM_VALUE_THESES
        @hyacinth_adapter.genre_uri = Sword::Constants::GENRE_TERM_URI_THESES
        @hyacinth_adapter.language_value = Sword::Constants::LANGUAGE_TERM_VALUE_ENGLISH
        @hyacinth_adapter.language_uri = Sword::Constants::LANGUAGE_TERM_URI_ENGLISH
        @hyacinth_adapter.type_of_resource = Sword::Constants::TYPE_OF_RESOURCE_VALUE_TEXT

        # set hyacinth fields for document-specific metadata
        @hyacinth_adapter.abstract = @proquest_etd_parser.abstract
        @hyacinth_adapter.date_issued_start = @proquest_etd_parser.date_conferred
        @hyacinth_adapter.title = @proquest_etd_parser.title
        process_name_metadata

        @deposit_title = @proquest_etd_parser.title
      end

      def process_degree_metadata
        degree = Sword::Metadata::Degree.new
        degree.name = @proquest_etd_parser.degree
        degree.discipline = proquest_etd_parser.institution_department_name
        degree.level = '2'
        degree.grantor = 'Columbia University'
        @hyacinth_adapter.degree = degree
      end

      def process_institution_info_into_corporate_name
        named_entity = Sword::Metadata::NamedEntity.new
        named_entity.type = 'corporate'
        # code 0054 is used for GSAS deposits
        if @proquest_etd_parser.institution_school_code == '0054'
          if @proquest_etd_parser.institution_department_name.start_with? 'TC:'
            named_entity.corporate_name =
              'Teachers College.' + @proquest_etd_parser.institution_department_name.sub('TC:','')
          else
            named_entity.corporate_name =
              @proquest_etd_parser.institution_name + '. ' +
              @proquest_etd_parser.institution_department_name
          end
        # Code 0055 is used for Teachers College deposits
        elsif @proquest_etd_parser.institution_school_code == '0055'
          named_entity.corporate_name =
            'Teachers College. ' + @proquest_etd_parser.institution_department_name
        else
            named_entity.corporate_name =
              @proquest_etd_parser.institution_name + '. ' +
              @proquest_etd_parser.institution_department_name
        end
        @hyacinth_adapter.names << named_entity
      end

      # rename this to process_names_metadata (plural: names)?
      def process_name_metadata
        @proquest_etd_parser.names.each do |named_entity|
            @hyacinth_adapter.names << named_entity
        end
      end
    end
  end
end
