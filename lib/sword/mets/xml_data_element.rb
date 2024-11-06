# frozen_string_literal: true

class Sword::Mets::XmlDataElement
  attr_accessor :abstract,
                :title

  def initialize(nokogiri_xml_element, xpath_info)
    @xml_data = nokogiri_xml_element
    @xpath_info = xpath_info
  end

  def parse
    @abstract = @xml_data.xpath(@xpath_info[:abstract], @xpath_info[:namespace]).text
    @title = @xml_data.xpath(@xpath_info[:title], @xpath_info[:namespace]).text
  end
end
