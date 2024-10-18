# frozen_string_literal: true

class Sword::Mets::ProquestMetsFile < Sword::Mets::MetsFile
  include Sword::Mets::ProquestConstants

  attr_accessor :abstract,
                :title,
                :xml_data,
                :xpath_info

  def initialize(nokogiri_xml_doc)
    super
    @xpath_info = XPATH_INFO
    # @xml_data = Sword::Mets::XmlDataElement.new(nokogiri_xml_doc, XPATH_HASH)
    @xml_data = find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    # md_wrap_proquest_xml_data_element = find_md_wrap_xml_data_elements(mdtype: OTHER, other_mdtype: OTHER_MDTYPE)
    md_wrap_proquest_xml_data_element = find_md_wrap_xml_data_element(mdtype: OTHER, other_mdtype: OTHER_MDTYPE)
    @xml_data_element = Sword::Mets::XmlDataElement.new(md_wrap_proquest_xml_data_element, XPATH_INFO)
    @abstract = @xml_data_element.abstract
    @title = @xml_data_element.title
  end
end
