# frozen_string_literal: true

class Sword::Mets::ModsXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :authors,
                :license_uri,
                :note_internal,
                :use_and_reproduction_uri

  def initialize(nokogiri_xml_element, xpath_info)
    super
    @authors = []
    @subjects = []
  end

  def parse
    super
    parse_authors
    parse_license_uri
    parse_note_internal
    parse_use_and_reproduction_uri
  end

  def parse_authors
    @xml_data.xpath(@xpath_info[:author], @xpath_info[:namespace]).each do |author|
      @authors << author.text
    end
  end

  def parse_license_uri
    @license_uri = @xml_data.xpath(@xpath_info[:license_uri], @xpath_info[:namespace]).attr('href').text
  end

  def parse_note_internal
    @note_internal = @xml_data.xpath(@xpath_info[:note_internal], @xpath_info[:namespace]).text
  end

  def parse_use_and_reproduction_uri
    @use_and_reproduction_uri =
      @xml_data.xpath(@xpath_info[:use_and_reproduction_uri], @xpath_info[:namespace]).attr('href').text
  end
end
