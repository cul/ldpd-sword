# frozen_string_literal: true

class Sword::Mets::ProquestMetsFile < Sword::Mets::MetsFile
  include Sword::Mets::ProquestConstants

  attr_accessor :diss_submission,
                :xml_data

  def initialize(nokogiri_xml_doc)
    super
    # @xml_data = Sword::Mets::XmlDataElement.new(nokogiri_xml_doc, XPATH_HASH)
    @xml_data = find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    md_wrap_proquest_xml_data_element = find_md_wrap_xml_data_elements(mdtype: OTHER, other_mdtype: OTHER_MDTYPE)
    @diss_submission = Sword::Mets::XmlDataElement.new(md_wrap_proquest_xml_data_element, { hi: 'Dude' })
  end
end
