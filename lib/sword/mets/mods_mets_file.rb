# frozen_string_literal: true

class Sword::Mets::ModsMetsFile < Sword::Mets::MetsFile
  include Sword::Mets::ModsConstants

  attr_accessor :abstract,
                :authors,
                :license_uri,
                :note_internal,
                :use_and_reproduction_uri,
                :title,
                :xml_data,
                :xpath_info

  def initialize(nokogiri_xml_doc)
    super
    @xpath_info = XPATH_INFO
    md_wrap_xml_data_element = find_md_wrap_xml_data_element(mdtype: 'MODS')
    @xml_data_element = Sword::Mets::ModsXmlDataElement.new(md_wrap_xml_data_element, XPATH_INFO)
  end

  def parse
    @xml_data_element.parse
    @abstract = @xml_data_element.abstract
    @authors = @xml_data_element.authors
    @license_uri = @xml_data_element.license_uri
    @note_internal = @xml_data_element.note_internal
    @use_and_reproduction_uri = @xml_data_element.use_and_reproduction_uri
    @title = @xml_data_element.title
  end
end
