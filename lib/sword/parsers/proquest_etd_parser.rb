# Parser based on mets.xml files received from ProQuest, and the DTD found at
# http://www.etdadmin.com/dtds/etd.dtd
module Sword
  module Parsers
    class ProquestEtdParser

      attr_accessor :abstract,
                    :date_conferred,
                    :degree,
                    :institution_department_name,
                    :institution_name,
                    :institution_school_code,
                    :names,
                    :title

      def initialize
        @names = []
      end

      def parse(xmlData_nokogiri_xml)
        # From DTD (see comment at top of file):
        # DISS_abstract contains one or more paragraphs of text abstract from the author
        @abstract =
          xmlData_nokogiri_xml.css("DISS_content>DISS_abstract").first.text

        # From DTD (see comment at top of file):
        # DISS_comp_date refers to the year the degree was conferred
        @date_conferred =
          xmlData_nokogiri_xml.css("DISS_description>DISS_dates>DISS_comp_date").first.text

        # From DTD (see comment at top of file):
        # Conforms to ProQuest list of degree acronyms
        @degree =
          xmlData_nokogiri_xml.css("DISS_description>DISS_degree").first.text

        # From DTD (see comment at top of file):
        # Department name within the institution
        @institution_department_name =
          xmlData_nokogiri_xml.css("DISS_description>DISS_institution>DISS_inst_contact").first.text

        # From DTD (see comment at top of file):
        # the name of the degree granting institution
        @institution_name =
          xmlData_nokogiri_xml.css("DISS_description>DISS_institution>DISS_inst_name").first.text

        # From DTD (see comment at top of file):
        # DISS_inst_code is a PQ-assigned school code
        @institution_school_code =
          xmlData_nokogiri_xml.css("DISS_description>DISS_institution>DISS_inst_code").first.text

        # From DTD (see comment at top of file):
        # DISS_title is the full title of the dissertation
        @title =
          xmlData_nokogiri_xml.css("DISS_title").first.text


        parse_authors xmlData_nokogiri_xml
        parse_advisors xmlData_nokogiri_xml
      end

      def parse_authors(nokogiri_xml)
        nokogiri_xml.css("DISS_authorship>DISS_author").each do |author|
          person = Sword::Metadata::NamedEntity.new
          person.type = 'personal'
          person.last_name = author.css("DISS_surname").text
          person.first_name = author.css("DISS_fname").text
          person.middle_name = author.css("DISS_middle").text
          person.role = 'author'
          # person.affiliation = getAffiliation(contentXml)
          # person.degree = DEGREE
          # person.degree_grantor = DEGREE_GRANTOR
          @names << person
        end
      end

      def parse_advisors(nokogiri_xml)
        nokogiri_xml.css("DISS_description>DISS_advisor").each do |advisor|
          person = Sword::Metadata::NamedEntity.new
          person.type = 'personal'
          person.last_name = advisor.css("DISS_surname").text
          person.first_name = advisor.css("DISS_fname").text
          person.middle_name = advisor.css("DISS_middle").text
          person.role = 'advisor'
          # person.affiliation = getAffiliation(contentXml)
          # person.degree = DEGREE
          # person.degree_grantor = DEGREE_GRANTOR
          @names << person
        end
      end

      def orig_mods_parse(xmlData_as_nokogiri_xml_element)
        @abstract = xmlData_as_nokogiri_xml_element.xpath('//mods:abstract').text
        @date_issued_start = xmlData_as_nokogiri_xml_element.xpath("//mods:originInfo/mods:dateIssued").text
        @identifier_doi = xmlData_as_nokogiri_xml_element.xpath("//mods:identifier[@type='doi']").text
        @identifier_uri = xmlData_as_nokogiri_xml_element.xpath("//mods:identifier[@type='uri']").text
        @note_internal = xmlData_as_nokogiri_xml_element.xpath("//mods:note[@type='internal']").text
        xmlData_as_nokogiri_xml_element.xpath('//mods:name').each do |mods_name_as_nokogiri_xml_element|
          names << parseModsName(mods_name_as_nokogiri_xml_element)
        end
          @record_info_note = xmlData_as_nokogiri_xml_element.xpath("//mods:recordInfo/mods:recordInfoNote").text
          @title = xmlData_as_nokogiri_xml_element.xpath('//mods:title').text
      end

      # fcd1, 07/05/18: Come up with better method name
      def readInXml(xml_file)
        # following is basically legacy hypatia code
        open(xml_file) do |b|
          file_data = b.read
          file_data.sub!('xmlns="http://www.etdadmin.com/ns/etdsword"', '')
          # substitute CRNL for NL
          file_data.gsub!(/\x0D(\x0A)?/,0x0A.chr)
          # replace all control characters but NL and TAB
          file_data.gsub!(/[\x01-\x08]/,'')
          file_data.gsub!(/[\x0B-\x1F]/,'')
          Nokogiri::XML(file_data)
        end
      end

      def parseModsName nokogiri_xml
          mods_name = Sword::Metadata::ModsName.new
          # currently, if multiple <namePart> are contained with one <name>, the contents
          # of the <nameParts> will be concatenated into one string, in the order in which
          # they are return by the xpath method. For now, this should be an acceptable default
          # behavior since we should only get one ,namePart> per <name>. However, if this is
          # not the case in the future, the code will need to be modified. For exmaple, it can
          # check the value of the 'type' attribute to see if it is set to 'family' or 'given'
          # and act accordingly, for example concatenate as "<family>, <given>"
          mods_name.name_part =
            nokogiri_xml.xpath('./mods:namePart').map{|e| e.text}.join(' ')
          mods_name.id = nokogiri_xml['ID']
          mods_name.type = nokogiri_xml['type']
          # for now, assume just one <role><roleTerm> per <name>
          mods_name.role.role_term = nokogiri_xml.xpath('./mods:role/mods:roleTerm').first.text
          mods_name.role.role_term_type =
            nokogiri_xml.xpath("./mods:role/mods:roleTerm").first['type']
          mods_name.role.role_term_authority =
            nokogiri_xml.xpath("./mods:role/mods:roleTerm").first['authority']
          mods_name.role.role_term_value_uri =
            nokogiri_xml.xpath("./mods:role/mods:roleTerm").first['valueURI']
          mods_name
      end
    end
  end
end
