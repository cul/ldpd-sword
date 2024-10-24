# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::XmlDataElement do
  describe 'initialize with Proquest data and after parse' do
    before(:context) do
      xpath_info =
        { namespace: { 'etdsword' => 'http://www.etdadmin.com/ns/etdsword' },
          abstract: '//etdsword:DISS_abstract',
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
  end

  describe 'initialize with Springer Nature data and after parse' do
    before(:context) do
      xpath_info =
        { namespace: { 'epdcx' => 'http://purl.org/eprint/epdcx/2006-11-16/' },
          abstract: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/terms/abstract"]',
          title: '//epdcx:statement[@epdcx:propertyURI="http://purl.org/dc/elements/1.1/title"]' }
      sn_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/SN_mets.xml').read)
      xml_data_sn = sn_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'EPDCX')
      @sn_xml_data = described_class.new(xml_data_sn, xpath_info)
      @sn_xml_data.parse
    end

    it 'sets the abstract correctly' do
      expect(@sn_xml_data.abstract).to include('the associations between post-traumatic stress disorder')
    end

    it 'sets the title correctly' do
      expect(@sn_xml_data.title).to include('among refugee women in Jordan: post-traumatic stress disorder')
    end
  end

  describe 'initialize with AC data and after parse' do
    before(:context) do
      xpath_info =
        { namespace: { 'mods' => 'http://www.loc.gov/mods/v3' },
          abstract: '//mods:abstract',
          title: '//mods:titleInfo/mods:title' }
      ac_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/AC_mets.xml').read)
      xml_data_ac = ac_mets_file.find_md_wrap_xml_data_element(mdtype: 'MODS')
      @ac_xml_data = described_class.new(xml_data_ac, xpath_info)
      @ac_xml_data.parse
    end

    it 'sets the abstract correctly' do
      expect(@ac_xml_data.abstract).to include('originally published in The Book of Zloczew')
    end

    it 'sets the title correctly' do
      expect(@ac_xml_data.title).to include('Gita May: A Life')
    end
  end
end
