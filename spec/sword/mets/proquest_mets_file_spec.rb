# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ProquestMetsFile do
  describe 'at initialization' do
    before(:context) do
      # @pq_mets_file = described_class.new(Nokogiri::XML(file_fixture('xml/mets/PQ_mets.xml').read))
      @pq_mets_file = described_class.new(file_fixture('xml/mets/PQ_mets.xml').read)
    end

    it 'sets md_wrap_xml_data_elements correctly' do
      md_wrap_xml_data_elements = @pq_mets_file.md_wrap_xml_data_elements
      expect(md_wrap_xml_data_elements.length).to eq(2)
      expect(md_wrap_xml_data_elements.first.name).to eq('xmlData')
    end
  end

  describe 'after parsing' do
    before(:context) do
      @pq_mets_file = described_class.new(file_fixture('xml/mets/PQ_mets.xml').read)
      @pq_mets_file.parse
    end

    it 'sets the title correctly' do
      expect(@pq_mets_file.title).to include('Unraveling the logic')
    end

    it 'sets the abstract correctly' do
      expect(@pq_mets_file.abstract).to include('relief of Rad inhibition of cardiac')
    end

    it 'sets the subjects correctly' do
      expect(@pq_mets_file.subjects).to include('Molecular biology')
      expect(@pq_mets_file.subjects).to include('Pharmacology')
      expect(@pq_mets_file.subjects).to include('Physiology')
    end

    it 'sets the authors correctly' do
      expect(@pq_mets_file.authors.first.first_name).to include('Ariana')
      expect(@pq_mets_file.authors.first.middle_name).to include('Cecilia')
      expect(@pq_mets_file.authors.first.last_name).to include('Gavin')
    end

    it 'sets the comp_date correctly' do
      expect(@pq_mets_file.comp_date).to eq('2024')
    end

    it 'sets the degree correctly' do
      expect(@pq_mets_file.degree).to eq('Ph.D.')
    end

    it 'sets the embargo code correctly' do
      expect(@pq_mets_file.embargo_code).to eq('0')
    end

    it 'sets the institution code correctly' do
      expect(@pq_mets_file.institution_code).to eq('0054')
    end

    it 'sets the institution contact correctly' do
      expect(@pq_mets_file.institution_contact).to eq('Pharmacology and Molecular Signaling')
    end

    it 'sets the institution name correctly' do
      expect(@pq_mets_file.institution_name).to eq('Columbia University')
    end
  end
end
