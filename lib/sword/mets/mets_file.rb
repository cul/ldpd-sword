# frozen_string_literal: true

class Sword::Mets::MetsFile
  class XmlData
    def initialize(nokogiri_xml_element, xpath_hash)
      @xml_data_nokogiri_element = nokogiri_xml_element
      @xpath_hash = xpath_hash
    end
  end

  attr_accessor :mets_hdr,
                :nokogiri_xml_doc,
                :md_wrap_xml_data_elements

  def initialize(mets_file)
    @nokogiri_xml_doc = Nokogiri::XML(mets_file)
    # @nokogiri_xml_doc = mets_file
    @mets_hdr = @nokogiri_xml_doc.xpath('//xmlns:metsHdr')
    @md_wrap_xml_data_elements = @nokogiri_xml_doc.xpath('//xmlns:mdWrap/xmlns:xmlData')
  end

  def find_md_wrap_xml_data_elements(mdtype: 'MODS', other_mdtype: nil)
    if other_mdtype
      @nokogiri_xml_doc.xpath("//xmlns:mdWrap[@MDTYPE = '#{mdtype}'][@OTHERMDTYPE = '#{other_mdtype}']/xmlns:xmlData")
    else
      @nokogiri_xml_doc.xpath("//xmlns:mdWrap[@MDTYPE = '#{mdtype}']/xmlns:xmlData")
    end
  end
end
