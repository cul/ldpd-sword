# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::EprintsDcXmlDataElement do
  describe 'after parsing' do
    before(:context) do
      xpath_info =
        { namespace: { 'epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/' },
          abstract: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/abstract"]',
          bibliographic_citation: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/eprint/terms/bibliographicCitation"]',
          creator: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/creator"]',
          date_available: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/available"]',
          identifier_uri: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/identifier"]/epdcx:valueString[@epdcx:sesURI="http://purl.org/dc/terms/URI"]',
          publisher: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/publisher"]',
          title: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/title"]' }
      sn_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/SN_mets.xml').read)
      xml_data = sn_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'EPDCX')
      @sn_xml_data = described_class.new(xml_data, xpath_info)
      @sn_xml_data.parse
    end

    it 'sets the abstract correctly' do
      expect(@sn_xml_data.abstract).to include('the associations between post-traumatic stress disorder')
    end

    it 'sets the bibliographic citation correctly' do
      expect(@sn_xml_data.bibliographic_citation).to include('Public Health. 2024 Sep 30;24(1)')
    end

    it 'sets the creators correctly' do
      expect(@sn_xml_data.creators).to include('Brooks, Mohamad A.')
      expect(@sn_xml_data.creators).to include('Bawaneh, Ahmad')
      expect(@sn_xml_data.creators).to include('El-Bassel, Nabila')
    end

    it 'sets the identifier URI correctly' do
      expect(@sn_xml_data.identifier_uri).to eq('https://doi.org/10.1186/s12889-024-20128-1')
    end

    it 'sets the publisher correctly' do
      expect(@sn_xml_data.publisher).to eq('BioMed Central')
    end

    it 'sets the title correctly' do
      expect(@sn_xml_data.title).to include('among refugee women in Jordan: post-traumatic stress disorder')
    end

    it 'sets the date available correctly' do
      expect(@sn_xml_data.date_available).to eq('2024-09-30')
    end
  end
end
