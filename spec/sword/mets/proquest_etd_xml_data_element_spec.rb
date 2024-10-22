# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ProquestEtdXmlDataElement do
  let(:xpath_info) do
    { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
      abstract: '//etdsword:DISS_abstract',
      author_name: '//etdsword:DISS_author/etdsword:DISS_name',
      first_name: 'etdsword:DISS_fname',
      middle_name: 'etdsword:DISS_middle',
      subjects: '//etdsword:DISS_cat_desc',
      surname: 'etdsword:DISS_surname',
      title: '//etdsword:DISS_title' }
  end

  describe 'at initialization' do
    before(:context) do
      @pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
      # @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
      @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    end

    it 'sets the abstract correctly' do
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      expect(pq_xml_data.abstract).to include('relief of Rad inhibition of cardiac')
    end

    it 'sets the title correctly' do
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      expect(pq_xml_data.title).to include('Unraveling the logic')
    end
  end

  describe 'after parsing' do
    before(:context) do
      @pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
      # @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
      @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    end

    it 'sets the subjects correctly' do
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      pq_xml_data.parse_subjects
      expect(pq_xml_data.subjects).to include('Molecular biology')
      expect(pq_xml_data.subjects).to include('Pharmacology')
      expect(pq_xml_data.subjects).to include('Physiology')
    end

    it 'sets the authors correctly' do
      pq_xml_data = described_class.new(@xml_data_proquest, xpath_info)
      pq_xml_data.parse_authors
      expect(pq_xml_data.authors.first.first_name).to include('Ariana')
      expect(pq_xml_data.authors.first.middle_name).to include('Cecilia')
      expect(pq_xml_data.authors.first.last_name).to include('Gavin')
    end
  end
end
