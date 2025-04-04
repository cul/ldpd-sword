require 'sword/endpoints/mets_to_hyacinth_endpoint.rb'
require 'sword/parsers/eprints_dc_xml_parser.rb'
require 'sword/metadata/note.rb'
require 'sword/metadata/parent_publication.rb'
require 'sword/metadata/personal_name.rb'

module Sword
  module Endpoints
    class EprintsEndpoint < MetsToHyacinthEndpoint

      attr_accessor :emails
      attr_reader :epdcx_parser,
                  :hyacinth_adapter

      def initialize(collection, depositor)
        super
        @epdcx_parser = Sword::Parsers::EprintsDcXmlParser.new
        @emails = []
      end

      def handle_deposit(path_to_contents)
        # handle_deposit from parent class will process the mets portion of the mets.xml file
        super

        # read eprints from mets.xml file and process metadata
        @epdcx_parser.parse @mets_parser.xmlData_as_nokogiri_xml_element.first

        # in an OJS mets.xml file, the email information is in a second xmlData element
        # which itself contains mods, with the email information within the mods
        if @mets_parser.xmlData_as_nokogiri_xml_element.length > 1
          name_identifiers_with_email = @mets_parser.xmlData_as_nokogiri_xml_element[1].css('mods|nameIdentifier[type="email"]', 'mods' => 'http://www.loc.gov/mods/v3')
          name_identifiers_with_email.each do |name_identifier_with_email|
            @emails << name_identifier_with_email.content
          end
        end

        process_metadata

        ingest_into_hyacinth
      end

      # This method takes the parsed metadata and maps it to the associated
      # field in HyacinthIngest object
      def process_metadata
        # fcd1, 08/20/18: May want to make sure there is a title, and throw an
        # exception if there isn't
        @hyacinth_adapter.encoder_item.title = @epdcx_parser.title

        @hyacinth_adapter.encoder_item.abstract = @epdcx_parser.abstract
        @hyacinth_adapter.encoder_item.date_issued_start = @epdcx_parser.date_available_year

        process_identifier unless @epdcx_parser.identifier.nil?
        process_name_metadata
        process_bibliographic_citation unless @epdcx_parser.bibliographic_citation.nil?
        process_subject_metadata unless @epdcx_parser.subjects.empty?
        process_name_identifier_email_metadata

        # fcd1, 08/20/18: Currently, this is mapped into the parent publication
        # doi, but it's the article doi. Can follow what is currently done for now.
        # @hyacinth_adapter.encoder_item.doi = @epdcx_parser.identifier_doi

        @deposit_title = @hyacinth_adapter.encoder_item.title

        # fcd1, 09/30/21: Both OJS and Springer Nature use this endpoint.
        # Springer Nature deposits include a bibliographic citation, which
        # is used to set parent publication fields, including publisher
        # and date available. However, OJS deposits do not include a
        # bibliographic citation, so other info in the mets.xml file
        # is used to set these two fields
        if @epdcx_parser.bibliographic_citation.nil?
          parent_publication = @hyacinth_adapter.encoder_item.parent_publication ||
                               Sword::Metadata::ParentPublication.new
          parent_publication.publish_date = @epdcx_parser.date_available_year
          parent_publication.title = @epdcx_parser.publisher
          @hyacinth_adapter.encoder_item.parent_publication = parent_publication
        end
      end

      def process_identifier
        parent_publication = @hyacinth_adapter.encoder_item.parent_publication ||
                             Sword::Metadata::ParentPublication.new
        parent_publication.doi =
          # remove url prefix, just want the DOI
          @epdcx_parser.identifier.gsub(/^\S*\/10.1/,'10.1')
        @hyacinth_adapter.encoder_item.parent_publication = parent_publication
      end

      def process_bibliographic_citation
        parent_publication = @hyacinth_adapter.encoder_item.parent_publication ||
                             Sword::Metadata::ParentPublication.new
        parent_publication.issue = @epdcx_parser.bibliographic_citation.issue
        parent_publication.title = @epdcx_parser.bibliographic_citation.title
        parent_publication.publish_date = @epdcx_parser.bibliographic_citation.publish_year
        parent_publication.start_page = @epdcx_parser.bibliographic_citation.start_page
        parent_publication.volume = @epdcx_parser.bibliographic_citation.volume
        @hyacinth_adapter.encoder_item.parent_publication = parent_publication
      end

      def process_subject_metadata
        # Currently, subjects listed in the incoming metadata are inserted into
        # a notes field in hyacinth, as per the requirements from CDRS
        subjects_string = ''
        @epdcx_parser.subjects.each do |subject|
          subjects_string << subject << ', '
        end
        @hyacinth_adapter.encoder_item.notes << Sword::Metadata::Note.new(subjects_string.chomp(', '))
      end

      def process_name_identifier_email_metadata
        return if @emails.empty?
        # Currently, emails listed in the incoming metadata are inserted into
        # a notes field in hyacinth, as per the requirements for OJS journals
        email_string = ''
        @emails.each do |email|
          email_string << email << ', '
        end
        @hyacinth_adapter.encoder_item.notes << Sword::Metadata::Note.new(email_string.chomp(', '))
      end

      def process_name_metadata
        @epdcx_parser.creators.each do |creator|
          individual = Sword::Metadata::PersonalName.new
          individual.role = 'author'
          individual.full_name_naf_format = creator
          @hyacinth_adapter.encoder_item.personal_names << individual
        end
      end
    end
  end
end
