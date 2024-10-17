# frozen_string_literal: true

class Sword::Mets::XmlDataElement
  attr_accessor :abstract,
                :advisors,
                :authors,
                :subjects,
                :title

  def initialize(nokogiri_xml_element, xpath_hash)
    @xml_data_nokogiri_element = nokogiri_xml_element
    @xpath_hash = xpath_hash
    # @title = @xml_data_nokogiri_element.xpath(@xpath_hash[:title].to_s)
    @title = @xml_data_nokogiri_element.xpath('//tt:DISS_title', 'tt' => 'http://www.etdadmin.com/ns/etdsword').text
  end
end
