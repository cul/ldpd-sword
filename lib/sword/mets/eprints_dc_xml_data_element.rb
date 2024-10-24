# frozen_string_literal: true

class Sword::Mets::EprintsDcXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :date_available

  def initialize(nokogiri_xml_element, xpath_info)
    super
    @authors = []
    @subjects = []
  end

  def parse
    super
    parse_date_available
  end

  def parse_date_available
    @date_available = @xml_data.xpath(@xpath_info[:date_available], @xpath_info[:namespace]).text.strip
  end
end
