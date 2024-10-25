# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ModsXmlDataElement do
  describe 'after parsing' do
    before(:context) do
      xpath_info =
        { namespace: { 'mods' => 'http://www.loc.gov/mods/v3' },
          abstract: '//mods:abstract',
          author: '//mods:namePart',
          license_uri: '//mods:accessCondition[@displayLabel="License"]',
          note_internal: '//mods:note[@type="internal"]',
          title: '//mods:titleInfo/mods:title',
          use_and_reproduction_uri: '//mods:accessCondition[@displayLabel="Rights Status"]' }
      ac_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/AC_mets.xml').read)
      xml_data = ac_mets_file.find_md_wrap_xml_data_element(mdtype: 'MODS')
      @ac_xml_data = described_class.new(xml_data, xpath_info)
      @ac_xml_data.parse
    end

    it 'sets the abstract correctly' do
      expect(@ac_xml_data.abstract).to include('originally published in The Book of Zloczew')
    end

    it 'sets the authors correctly' do
      expect(@ac_xml_data.authors).to include('Force, Pierre')
    end

    it 'sets the license uri correctly' do
      expect(@ac_xml_data.license_uri).to include('creativecommons.org/licenses/by/4.0')
    end

    it 'sets the title correctly' do
      expect(@ac_xml_data.title).to include('Gita May: A Life')
    end

    it 'sets the note (type: internal) correctly' do
      expect(@ac_xml_data.note_internal).to include('by publisher - article appears')
    end

    it 'sets the use and reproduction URI correctly' do
      expect(@ac_xml_data.use_and_reproduction_uri).to include('rightsstatements.org/vocab/InC/1.')
    end
  end
end
