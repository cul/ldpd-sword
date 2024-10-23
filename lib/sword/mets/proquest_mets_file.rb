# frozen_string_literal: true

class Sword::Mets::ProquestMetsFile < Sword::Mets::MetsFile
  include Sword::Mets::ProquestConstants

  attr_accessor :abstract,
                :authors,
                :comp_date,
                :degree,
                :embargo_code,
                :institution_code,
                :institution_contact,
                :institution_name,
                :subjects,
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
    @xml_data_element = Sword::Mets::ProquestEtdXmlDataElement.new(md_wrap_proquest_xml_data_element, XPATH_INFO)
  end

  def parse
    @xml_data_element.parse
    @abstract = @xml_data_element.abstract
    @comp_date = @xml_data_element.comp_date
    @degree = @xml_data_element.degree
    @embargo_code = @xml_data_element.embargo_code
    @institution_code = @xml_data_element.institution_code
    @institution_contact = @xml_data_element.institution_contact
    @institution_name = @xml_data_element.institution_name
    @authors = @xml_data_element.authors
    @subjects = @xml_data_element.subjects
    @title = @xml_data_element.title
  end
end
