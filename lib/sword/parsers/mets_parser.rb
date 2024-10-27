module Sword
  module Parsers
    class MetsParser

      attr_reader :agent_name,
                  :flocat_xlink_href,
                  :xmlData_as_nokogiri_xml_element

      def parse(mets_xml_file)
        nokogiri_xml = readInXml(mets_xml_file)
        @flocat_xlink_href = []
        flocat_xlink_href_xpath =
          '/xmlns:mets/xmlns:fileSec/xmlns:fileGrp/xmlns:file/xmlns:FLocat'
        nokogiri_xml.xpath(flocat_xlink_href_xpath).each do |flocat|
          @flocat_xlink_href << flocat.attributes['href'].text
        end
        agent_name_xml =
          nokogiri_xml.xpath('/xmlns:mets/xmlns:metsHdr/xmlns:agent/xmlns:name')
        @agent_name = agent_name_xml.first.text unless agent_name_xml.empty?
        @xmlData_as_nokogiri_xml_element = []
        nokogiri_xml.xpath('/xmlns:mets/xmlns:dmdSec/xmlns:mdWrap/xmlns:xmlData').each do |xml_data|
          @xmlData_as_nokogiri_xml_element << xml_data
        end
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

    end
  end
end
