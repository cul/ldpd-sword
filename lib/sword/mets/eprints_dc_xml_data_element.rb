# frozen_string_literal: true

class Sword::Mets::EprintsDcXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :bibliographic_citation,
                :creators,
                :date_available,
                :identifier_uri,
                :publisher

  def initialize(nokogiri_xml_element, xpath_info)
    super
    @creators = []
    @subjects = []
  end

  def parse
    super
    parse_bibliographic_citation
    parse_creators
    parse_date_available
    parse_identifier_uri
    parse_publisher
  end

  def parse_creators
    @xml_data.xpath(@xpath_info[:creator], @xpath_info[:namespace]).each do |creator|
      @creators << creator.text.strip
    end
  end

  def parse_date_available
    @date_available = @xml_data.xpath(@xpath_info[:date_available], @xpath_info[:namespace]).text.strip
  end

  def parse_identifier_uri
    @identifier_uri = @xml_data.xpath(@xpath_info[:identifier_uri], @xpath_info[:namespace]).text.strip
  end

  def parse_publisher
    @publisher = @xml_data.xpath(@xpath_info[:publisher], @xpath_info[:namespace]).text.strip
  end

  def parse_bibliographic_citation
    @bibliographic_citation = @xml_data.xpath(@xpath_info[:bibliographic_citation], @xpath_info[:namespace]).text.strip
  end
end
