module Sword
  module Endpoints
    class EprintsEndpoint < MetsToHyacinthEndpoint

      attr_reader :epdcx_parser,
                  :hyacinth_adapter

      def initialize(collection, depositor)
        super
        @epdcx_parser = Sword::Parsers::EprintsDcXmlParser.new
      end

      def handle_deposit(path_to_contents)
        # handle_deposit from parent class will process the mets portion of the mets.xml file
        super

        # read mods from mets.xml file and process metadata
        @epdcx_parser.parse @mets_parser.xmlData_as_nokogiri_xml_element.first
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
        # fcd1, 08/20/18: May want to make sure there is a title, and throw an
        # exception if there isn't
        @hyacinth_adapter.title = @epdcx_parser.title

        @hyacinth_adapter.abstract = @epdcx_parser.abstract
        @hyacinth_adapter.date_issued_start = @epdcx_parser.date_available_year

        process_identifier_uri unless @epdcx_parser.identifier_uri.nil?
        process_name_metadata
        process_bibliographic_citation unless @epdcx_parser.bibliographic_citation.nil?
        process_subject_metadata unless @epdcx_parser.subjects.empty?

        # fcd1, 08/20/18: Currently, this is mapped into the parent publication
        # doi, but it's the article doi. Can follow what is currently done for now.
        # @hyacinth_adapter.doi = @epdcx_parser.identifier_doi

        @deposit_title = @hyacinth_adapter.title

        # fcd1, 07/29/21: Both OJS and Springer Nature use this endpoint.
        # For Springer Nature deposits, the parent_publication.publish_date
        # is set using the bibliographic citation (see process_bibliographic_citation
        # below). This value is then used to set the parent_publication_date_created_textual
        # in hyacinth.
        # In OJS deposits, we want to use @epdcx_parser.date_available_year to set
        # the parent_publication_date_created_textual field in hyacinth, since OJS deposits do
        # not include the bibliographic citation. So the logic here to handle both OJS and
        # Springer Natuer deposits: if @hyacinth_adapter.parent_publication is nil, we
        # will assume there was no bibliographic citation to process, so we will use the
        # @epdcx_parser.date_available_year value to set parent_publication.publish_date,
        # if present
        # Also: For Springer Nature deposits, the parent_publication.title
        # is set using the bibliographic citation (see process_bibliographic_citation
        # below). This value is then used to set parent_publication_title_sort_portion
        # in hyacinth.
        # In OJS deposits, we want to use @epdcx_parser.publisher to set
        # the parent_publication_title_sort_portion field in hyacinth, since OJS deposits do
        # not include the bibliographic citation. So the logic here to handle both OJS and
        # Springer Natuer deposits: if @hyacinth_adapter.parent_publication is nil, we
        # will assume there was no bibliographic citation to process, so we will use the
        # @epdcx_parser.publisher value to set parent_publication_title_sort_portion,
        # if present
        unless @hyacinth_adapter.parent_publication
          @hyacinth_adapter.parent_publication = Sword::Metadata::ParentPublication.new
          @hyacinth_adapter.parent_publication.publish_date = @epdcx_parser.date_available_year
          @hyacinth_adapter.parent_publication.title = @epdcx_parser.publisher
        end
      end

      def process_identifier_uri
        parent_publication = @hyacinth_adapter.parent_publication ||
                             Sword::Metadata::ParentPublication.new
        parent_publication.doi =
          # remove url prefix, just want the DOI
          @epdcx_parser.identifier_uri.gsub(/^\S*\/10.1/,'10.1')
        @hyacinth_adapter.parent_publication = parent_publication
      end

      def process_bibliographic_citation
        parent_publication = @hyacinth_adapter.parent_publication ||
                             Sword::Metadata::ParentPublication.new
        parent_publication.issue = @epdcx_parser.bibliographic_citation.issue
        parent_publication.title = @epdcx_parser.bibliographic_citation.title
        parent_publication.publish_date = @epdcx_parser.bibliographic_citation.publish_year
        parent_publication.start_page = @epdcx_parser.bibliographic_citation.start_page
        parent_publication.volume = @epdcx_parser.bibliographic_citation.volume
        @hyacinth_adapter.parent_publication = parent_publication
      end

      def process_subject_metadata
        # Currently, subjects listed in the incoming metadata are inserted into
        # a notes field in hyacinth, as per the requirements from CDRS
        subjects_string = ''
        @epdcx_parser.subjects.each do |subject|
          subjects_string << subject << ', '
        end
        @hyacinth_adapter.note_value = subjects_string.chomp ', '
      end

      def process_name_metadata
        @epdcx_parser.creators.each do |creator|
          individual = Sword::Metadata::PersonalName.new
          individual.role = 'author'
          individual.full_name_naf_format = creator
          @hyacinth_adapter.personal_names << individual
        end
      end
    end
  end
end
