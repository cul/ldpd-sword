# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ProquestEtdXmlDataElement do
  describe 'at initialization' do
    before(:context) do
      @pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
      # @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
      @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    end

    it 'sets the abstract correctly' do
      xpath_info = { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
                     abstract: '//etdsword:DISS_abstract' }
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      expect(pq_xml_data.abstract).to include('relief of Rad inhibition of cardiac')
    end

    it 'sets the subjects correctly' do
      xpath_info = { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
                     subjects: '//etdsword:DISS_cat_desc' }
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      pq_xml_data.parse_subjects
      expect(pq_xml_data.subjects).to include('Molecular biology')
      expect(pq_xml_data.subjects).to include('Pharmacology')
      expect(pq_xml_data.subjects).to include('Physiology')
    end

    it 'sets the title correctly' do
      xpath_info = { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
                     title: '//etdsword:DISS_title' }
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      expect(pq_xml_data.title).to include('Unraveling the logic')
    end
  end
end
