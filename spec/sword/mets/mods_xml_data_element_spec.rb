# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ModsXmlDataElement do
  describe 'after parsing' do
    before(:context) do
      xpath_info =
        { namespace: { 'mods' => 'http://www.loc.gov/mods/v3' },
          abstract: '//mods:abstract',
          note_internal: '//mods:note[@type="internal"]',
          title: '//mods:titleInfo/mods:title' }
      ac_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/AC_mets.xml').read)
      xml_data = ac_mets_file.find_md_wrap_xml_data_element(mdtype: 'MODS')
      @ac_xml_data = described_class.new(xml_data, xpath_info)
      @ac_xml_data.parse
    end

    it 'sets the abstract correctly' do
      expect(@ac_xml_data.abstract).to include('originally published in The Book of Zloczew')
    end

    it 'sets the title correctly' do
      expect(@ac_xml_data.title).to include('Gita May: A Life')
    end

    it 'sets the note (type: internal) correctly' do
      expect(@ac_xml_data.note_internal).to include('by publisher - article appears')
    end
  end
end
