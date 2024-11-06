# frozen_string_literal: true

class Sword::Mets::EprintsDcMetsFile < Sword::Mets::MetsFile
  include Sword::Mets::EprintsDcConstants

  attr_accessor :abstract,
                :bibliographic_citation,
                :creators,
                :date_available,
                :identifier_uri,
                :publisher,
                :title,
                :xpath_info

  def initialize(nokogiri_xml_doc)
    super
    @xpath_info = XPATH_INFO
    md_wrap_xml_data_element = find_md_wrap_xml_data_element(mdtype: OTHER, other_mdtype: OTHER_MDTYPE)
    @xml_data_element = Sword::Mets::EprintsDcXmlDataElement.new(md_wrap_xml_data_element, XPATH_INFO)
  end

  def parse
    @xml_data_element.parse
    @abstract = @xml_data_element.abstract
    @bibliographic_citation = @xml_data_element.bibliographic_citation
    @creators = @xml_data_element.creators
    @date_available = @xml_data_element.date_available
    @identifier_uri = @xml_data_element.identifier_uri
    @publisher = @xml_data_element.publisher
    @title = @xml_data_element.title
  end
end
