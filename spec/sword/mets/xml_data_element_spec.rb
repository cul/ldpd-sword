# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::XmlDataElement do
  describe 'at initialization' do
    before(:context) do
      @pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
      @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    end

    it 'sets md_wrap_xml_data_elements correctly' do
      xpath_hash = { title: "'//tt:DISS_title', 'tt' => 'http://www.etdadmin.com/ns/etdsword'" }
      pq_xml_data_element = described_class.new(@xml_data_proquest, xpath_hash)
      expect(pq_xml_data_element.title).to include('Unraveling the logic')
    end
  end
end
