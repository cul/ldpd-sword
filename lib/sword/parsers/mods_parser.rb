require 'sword/metadata/mods_name.rb'

module Sword
  module Parsers
    class ModsParser

      attr_accessor :abstract,
                    :access_condition_use_and_reproduction_license_uri,
                    :access_condition_use_and_reproduction_rights_status_uri,
                    :date_issued_start,
                    :identifier_uri,
                    :identifier_doi,
                    :names,
                    :note_internal,
                    :record_info_note,
                    :title

      def initialize
        @names = []
      end

      def parse(xmlData_nokogiri_xml)
        @abstract = xmlData_nokogiri_xml.xpath('//mods:abstract').text
        @date_issued_start = xmlData_nokogiri_xml.xpath("//mods:originInfo/mods:dateIssued").text
        @identifier_doi = xmlData_nokogiri_xml.xpath("//mods:identifier[@type='doi']").text
        @identifier_uri = xmlData_nokogiri_xml.xpath("//mods:identifier[@type='uri']").text
        @note_internal = xmlData_nokogiri_xml.xpath("//mods:note[@type='internal']").text
        xmlData_nokogiri_xml.xpath('//mods:name').each do |mods_name_as_nokogiri_xml_element|
          names << parseModsName(mods_name_as_nokogiri_xml_element)
        end
        @record_info_note = xmlData_nokogiri_xml.xpath("//mods:recordInfo/mods:recordInfoNote").text
        @title = xmlData_nokogiri_xml.xpath('//mods:title').text

        access_condition_license =
          xmlData_nokogiri_xml.xpath("//mods:accessCondition[@displayLabel='License']").first
        @access_condition_use_and_reproduction_license_uri =
          access_condition_license['xlink:href'] unless access_condition_license.nil?
        access_condition_right_status =
          xmlData_nokogiri_xml.xpath("//mods:accessCondition[@displayLabel='Rights Status']").first
        @access_condition_use_and_reproduction_rights_status_uri =
          access_condition_right_status['xlink:href'] unless access_condition_right_status.nil?
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
