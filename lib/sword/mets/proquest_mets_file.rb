# frozen_string_literal: true

class Sword::Mets::ProquestMetsFile < Sword::Mets::MetsFile
  class DissSubmission
    attr_reader :title

    def initialize(nokogiri_xml_doc)
      @diss_submission = nokogiri_xml_doc.first.children.find(&:element?)
    end
  end

  # attr_accessor :md_wrap_proquest_xml_data_element
  attr_accessor :diss_submission

  def initialize(nokogiri_xml_doc)
    super
    md_wrap_proquest_xml_data_element = find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    @diss_submission = DissSubmission.new md_wrap_proquest_xml_data_element
  end
end
