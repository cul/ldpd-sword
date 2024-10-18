# frozen_string_literal: true

class Sword::Mets::MetsFile
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

  def find_md_wrap_xml_data_element(mdtype: 'MODS', other_mdtype: nil)
    if other_mdtype
      @nokogiri_xml_doc.xpath(
        "//xmlns:mdWrap[@MDTYPE = '#{mdtype}'][@OTHERMDTYPE = '#{other_mdtype}']/xmlns:xmlData"
      ).first
    else
      @nokogiri_xml_doc.xpath("//xmlns:mdWrap[@MDTYPE = '#{mdtype}']/xmlns:xmlData").first
    end
  end
end
