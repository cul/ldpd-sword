# Parser based on EPDCX (EPrints DC XML) metadata format, which is the default metadata
# format used in SWORD deposits
module Sword
  module Parsers
    class EprintsDcXmlParser
      # following constant strings are used in the parsing functionality
      DC_PURL = 'http://purl.org/dc/elements/1.1/'
      STATEMENT = "epdcx|statement[epdcx|propertyURI='"
      PREFIX_DC_ELEMENTS = "epdcx|statement[epdcx|propertyURI='http://purl.org/dc/elements/1.1/"
      PREFIX_DC_TERMS = "epdcx|statement[epdcx|propertyURI='http://purl.org/dc/terms/"
      PREFIX_EPRINT_TERMS = "epdcx|statement[epdcx|propertyURI='http://purl.org/eprint/terms/"
      POSTFIX = "']>epdcx|valueString"
      POSTFIX_DOI = "']>epdcx|valueString[epdcx|sesURI='http://purl.org/dc/terms/URI']"
      POSTFIX_DATE = "']>epdcx|valueString[epdcx|sesURI='http://purl.org/dc/terms/W3CDTF']"
      EPDCX_NAMESPACE_BINDING = {'epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/'}

      attr_accessor :abstract,
                    :bibliographic_citation,
                    :creators,
                    :date_available,
                    :identifier_uri,
                    :publisher,
                    :subjects,
                    :title

      def initialize
        @creators = []
        @subjects = []
      end

      def date_available_year
        return nil if @date_available.nil?
        # only want the year
        date_available.slice(0,4)
      end

      # The abstract field in deposits from Springer Nature start with the word "Abstract",
      # which is redundant (since this is the field label) and therefore we get rid of it.
      def get_abstract(nokogiri_xml_doc)
        abstract_value_first = nokogiri_xml_doc.css("#{PREFIX_DC_TERMS}abstract#{POSTFIX}",
                                                         EPDCX_NAMESPACE_BINDING).first
        return nil if abstract_value_first.nil?
        abstract_value = abstract_value_first.text
        abstract_value.gsub(/^\s*Abstract\n/,'')
      end

      # http://purl.org/dc/terms/available
      # http://dublincore.org/documents/dcmi-terms/#terms-available
      def get_date_available(nokogiri_xml_doc)
        date_available_nokogiri_node = nokogiri_xml_doc.css("#{PREFIX_DC_TERMS}available#{POSTFIX}",
                                                            EPDCX_NAMESPACE_BINDING).first
        date_available_nokogiri_node.text if date_available_nokogiri_node
      end

      # http://purl.org/dc/elements/1.1/identifier
      # Idenfifier is a URI: http://purl.org/dc/terms/URI
      # in this case, uri will be a doi
      # http://dublincore.org/documents/dcmi-terms/#terms-identifier
      def get_identifier_uri(nokogiri_xml_doc)
        identifier_uri_nokogiri_node = nokogiri_xml_doc.css("#{PREFIX_DC_ELEMENTS}identifier#{POSTFIX_DOI}",
                                                            EPDCX_NAMESPACE_BINDING).first
        identifier_uri_nokogiri_node.text if identifier_uri_nokogiri_node
      end

      # http://purl.org/dc/elements/1.1/publisher
      # https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#http://purl.org/dc/terms/publisher
      def get_publisher(nokogiri_xml_doc)
        publisher_nokogiri_node = nokogiri_xml_doc.css("#{PREFIX_DC_ELEMENTS}publisher#{POSTFIX}",
                                                   EPDCX_NAMESPACE_BINDING).first
        publisher_nokogiri_node.text if publisher_nokogiri_node
      end

      # http://purl.org/dc/elements/1.1/title
      # http://dublincore.org/documents/dcmi-terms/#terms-title
      def get_title(nokogiri_xml_doc)
        title_nokogiri_node = nokogiri_xml_doc.css("#{PREFIX_DC_ELEMENTS}title#{POSTFIX}",
                                                   EPDCX_NAMESPACE_BINDING).first
        title_nokogiri_node.text if title_nokogiri_node
      end

      def parse(xmlData_nokogiri_xml)
        # From DTD (see comment at top of file):
        # DISS_abstract contains one or more paragraphs of text abstract from the author
        @abstract = get_abstract xmlData_nokogiri_xml
        @date_available = get_date_available xmlData_nokogiri_xml
        @identifier_uri = get_identifier_uri xmlData_nokogiri_xml
        @publisher = get_publisher xmlData_nokogiri_xml
        @title = get_title xmlData_nokogiri_xml

        parse_creators xmlData_nokogiri_xml
        parse_bibliographic_citation xmlData_nokogiri_xml
        parse_subjects xmlData_nokogiri_xml
      end

      # http://purl.org/eprint/terms/bibliographicCitation
      def parse_bibliographic_citation nokogiri_xml_doc
        bibliographic_citation_first = nokogiri_xml_doc.css(
          "#{PREFIX_EPRINT_TERMS}bibliographicCitation#{POSTFIX}",
          EPDCX_NAMESPACE_BINDING).first
        return nil if bibliographic_citation_first.nil?
        bibliographic_citation_text = bibliographic_citation_first.text
        # Here is an example of an entry from an actual mets.xml
        # International Journal of Mental Health Systems. 2016 Jan 04;10(1):1
        match = /^(.+)\. (\d\d\d\d) \w\w\w \d\d;(\d+)\((\d+)\):(\d*)/.match bibliographic_citation_text
        unless match.nil?
          biblio_citation = Sword::Metadata::EpdcxBibliographicCitation.new
          biblio_citation.title = match[1]
          biblio_citation.publish_year = match[2]
          biblio_citation.volume = match[3]
          biblio_citation.issue = match[4]
          biblio_citation.start_page = match[5]
          @bibliographic_citation = biblio_citation
        end
      end

      # http://purl.org/dc/elements/1.1/creator
      # http://dublincore.org/documents/dcmi-terms/#terms-creator
      def parse_creators(nokogiri_xml_doc)
        nokogiri_xml_doc.css("#{PREFIX_DC_ELEMENTS}creator#{POSTFIX}",
                             EPDCX_NAMESPACE_BINDING).each do |creator|
          creator_text = creator.text
          unless creator_text.include?(',')
            # standardize name to "Doe, John"
            creator_text_array = creator_text.split
            creator_text = creator_text_array.unshift(creator_text_array.pop + ',').join(' ')
          end
          @creators << creator_text
        end
      end

      # http://purl.org/dc/elements/1.1/subject
      # http://dublincore.org/documents/dcmi-terms/#terms-subject
      def parse_subjects(nokogiri_xml_doc)
        nokogiri_xml_doc.css("#{PREFIX_DC_ELEMENTS}subject#{POSTFIX}",
                             EPDCX_NAMESPACE_BINDING).each do |subject|
          @subjects << subject.text
        end
      end
    end
  end
end
