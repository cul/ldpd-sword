# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ProquestEtdXmlDataElement do
  describe 'after parsing' do
    before(:context) do
      xpath_info =
        { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
          abstract: '//etdsword:DISS_abstract',
          author_name: '//etdsword:DISS_author/etdsword:DISS_name',
          comp_date: '//etdsword:DISS_comp_date',
          degree: '//etdsword:DISS_degree',
          embargo_code: '//etdsword:DISS_submission/@embargo_code',
          institution_code: '//etdsword:DISS_inst_code',
          institution_contact: '//etdsword:DISS_inst_contact',
          institution_name: '//etdsword:DISS_inst_name',
          first_name: 'etdsword:DISS_fname',
          middle_name: 'etdsword:DISS_middle',
          subjects: '//etdsword:DISS_cat_desc',
          surname: 'etdsword:DISS_surname',
          title: '//etdsword:DISS_title' }
      pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
      xml_data_proquest = pq_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
      @pq_xml_data = described_class.new(xml_data_proquest, xpath_info)
      @pq_xml_data.parse
    end

    it 'sets the abstract correctly' do
      expect(@pq_xml_data.abstract).to include('relief of Rad inhibition of cardiac')
    end

    it 'sets the title correctly' do
      expect(@pq_xml_data.title).to include('Unraveling the logic')
    end

    it 'sets the subjects correctly' do
      expect(@pq_xml_data.subjects).to include('Molecular biology')
      expect(@pq_xml_data.subjects).to include('Pharmacology')
      expect(@pq_xml_data.subjects).to include('Physiology')
    end

    it 'sets the authors correctly' do
      expect(@pq_xml_data.authors.first.first_name).to include('Ariana')
      expect(@pq_xml_data.authors.first.middle_name).to include('Cecilia')
      expect(@pq_xml_data.authors.first.last_name).to include('Gavin')
    end

    it 'sets the comp_date correctly' do
      expect(@pq_xml_data.comp_date).to eq('2024')
    end

    it 'sets the degree correctly' do
      expect(@pq_xml_data.degree).to eq('Ph.D.')
    end

    it 'sets the embargo_code correctly' do
      expect(@pq_xml_data.embargo_code).to eq('0')
    end

    it 'sets the institution code correctly' do
      expect(@pq_xml_data.institution_code).to eq('0054')
    end

    it 'sets the institution contact correctly' do
      expect(@pq_xml_data.institution_contact).to eq('Pharmacology and Molecular Signaling')
    end

    it 'sets the institution name correctly' do
      expect(@pq_xml_data.institution_name).to eq('Columbia University')
    end
  end
end
