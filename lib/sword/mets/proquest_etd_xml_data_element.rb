# frozen_string_literal: true

class Sword::Mets::ProquestEtdXmlDataElement < Sword::Mets::XmlDataElement
  attr_accessor :subjects

  def initialize(nokogiri_xml_element, xpath_info)
    super
    @subjects = []
    # @xml_data = nokogiri_xml_element
    # @xpath_info = xpath_info
    # @title = @xml_data_nokogiri_element.xpath(@xpath_hash[:title].to_s)
    # @title = @xml_data.xpath('//tt:DISS_title', { 'tt' => 'http://www.etdadmin.com/ns/etdsword' }).text
    # @title = @xml_data.xpath("#{@xpath_info[:title]}", @xpath_info[:namespace]).text
    # @abstract = @xml_data.xpath(@xpath_info[:abstract], @xpath_info[:namespace]).text
    # @title = @xml_data.xpath(@xpath_info[:title], @xpath_info[:namespace]).text
  end

  def parse_subjects
    @diss_cat_descs = @xml_data.xpath(@xpath_info[:subjects], @xpath_info[:namespace])
    @diss_cat_descs.each do |diss_cat_desc|
      @subjects.push diss_cat_desc.text
    end
  end
end
