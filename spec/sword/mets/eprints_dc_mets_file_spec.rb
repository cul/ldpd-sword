# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::EprintsDcMetsFile do
  describe 'at initialization' do
    before(:context) do
      @sn_mets_file = described_class.new(file_fixture('xml/mets/SN_mets.xml').read)
    end

    it 'sets md_wrap_xml_data_elements correctly' do
      md_wrap_xml_data_elements = @sn_mets_file.md_wrap_xml_data_elements
      expect(md_wrap_xml_data_elements.length).to eq(1)
      expect(md_wrap_xml_data_elements.first.name).to eq('xmlData')
    end
  end

  describe 'after parsing' do
    before(:context) do
      @sn_mets_file = described_class.new(file_fixture('xml/mets/SN_mets.xml').read)
      @sn_mets_file.parse
    end

    it 'sets the abstract correctly' do
      expect(@sn_mets_file.abstract).to include('four health clinics throughout Jordan in 2018')
    end

    it 'sets the bibliographic citation correctly' do
      expect(@sn_mets_file.bibliographic_citation).to include('Public Health. 2024 Sep 30;24(1)')
    end

    it 'sets the creators correctly' do
      expect(@sn_mets_file.creators).to include('Brooks, Mohamad A.')
      expect(@sn_mets_file.creators).to include('Bawaneh, Ahmad')
      expect(@sn_mets_file.creators).to include('El-Bassel, Nabila')
    end

    it 'sets the data available correctly' do
      expect(@sn_mets_file.date_available).to eq('2024-09-30')
    end

    it 'sets the identifier URI correctly' do
      expect(@sn_mets_file.identifier_uri).to eq('https://doi.org/10.1186/s12889-024-20128-1')
    end

    it 'sets the publisher correctly' do
      expect(@sn_mets_file.publisher).to eq('BioMed Central')
    end

    it 'sets the title correctly' do
      expect(@sn_mets_file.title).to include('among refugee women in Jordan: post-traumatic stress disorder')
    end
  end
end
