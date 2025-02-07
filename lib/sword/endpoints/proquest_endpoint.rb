require 'sword/constants.rb'
require 'sword/endpoints/mets_to_hyacinth_endpoint.rb'
require 'sword/metadata/corporate_name.rb'
require 'sword/metadata/degree.rb'
require 'sword/parsers/proquest_etd_parser.rb'

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

        ingest_into_hyacinth
      end

      # This method takes the parsed metadata and maps it to the associated
      # field in HyacinthIngest object
      def process_metadata
        # set hyacinth fields for the "hard-coded" metadata
        @hyacinth_adapter.encoder_item.genre_value = Sword::Constants::GENRE_TERM_VALUE_THESES
        @hyacinth_adapter.encoder_item.genre_uri = Sword::Constants::GENRE_TERM_URI_THESES
        @hyacinth_adapter.encoder_item.language_value = Sword::Constants::LANGUAGE_TERM_VALUE_ENGLISH
        @hyacinth_adapter.encoder_item.language_uri = Sword::Constants::LANGUAGE_TERM_URI_ENGLISH
        @hyacinth_adapter.encoder_item.type_of_resource = Sword::Constants::TYPE_OF_RESOURCE_VALUE_TEXT

        # set hyacinth fields for document-specific metadata
        @hyacinth_adapter.encoder_item.abstract = @proquest_etd_parser.abstract
        @hyacinth_adapter.encoder_item.date_issued_start = @proquest_etd_parser.date_conferred
        @hyacinth_adapter.encoder_item.title = @proquest_etd_parser.title
        @hyacinth_adapter.encoder_item.embargo_release_date = @proquest_etd_parser.embargo_release_date

        process_name_metadata
        process_degree_metadata
        process_institution_info_into_corporate_name
        process_subject_metadata

        @deposit_title = @proquest_etd_parser.title
      end

      def process_degree_metadata
        degree = Sword::Metadata::Degree.new
        degree.name = @proquest_etd_parser.degree
        degree.discipline = proquest_etd_parser.institution_department_name
        degree.level = '2'
        degree.grantor = 'Columbia University'
        @hyacinth_adapter.encoder_item.degree = degree
      end

      def process_subject_metadata
        @hyacinth_adapter.encoder_item.subjects = @proquest_etd_parser.subjects
      end

      def process_institution_info_into_corporate_name
        corporate_name = Sword::Metadata::CorporateName.new
        # code 0054 is used for GSAS deposits
        if @proquest_etd_parser.institution_school_code == '0054'
          if @proquest_etd_parser.institution_department_name.start_with? 'TC:'
            corporate_name.name =
              'Teachers College.' + @proquest_etd_parser.institution_department_name.sub('TC:','')
          else
            corporate_name.name =
              @proquest_etd_parser.institution_name + '. ' +
              @proquest_etd_parser.institution_department_name
          end
        # Code 0055 is used for Teachers College deposits
        elsif @proquest_etd_parser.institution_school_code == '0055'
          corporate_name.name =
            'Teachers College. ' + @proquest_etd_parser.institution_department_name
        else
            corporate_name.name =
              @proquest_etd_parser.institution_name + '. ' +
              @proquest_etd_parser.institution_department_name
        end
        @hyacinth_adapter.encoder_item.corporate_names << corporate_name
      end

      # rename this to process_names_metadata (plural: names)?
      def process_name_metadata
        @proquest_etd_parser.names.each do |personal_name|
            @hyacinth_adapter.encoder_item.personal_names << personal_name
        end
      end
    end
  end
end
