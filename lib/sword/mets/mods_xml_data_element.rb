# frozen_string_literal: true

class Sword::Mets::ModsXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :note_internal

  def initialize(nokogiri_xml_element, xpath_info)
    super
    @authors = []
    @subjects = []
  end

  def parse
    super
    parse_note_internal
  end

  def parse_note_internal
    @note_internal = @xml_data.xpath(@xpath_info[:note_internal], @xpath_info[:namespace]).text
  end
end
