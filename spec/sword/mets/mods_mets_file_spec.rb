# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ModsMetsFile do
  describe 'at initialization' do
    before(:context) do
      @ac_mets_file = described_class.new(file_fixture('xml/mets/AC_mets.xml').read)
    end

    it 'sets md_wrap_xml_data_elements correctly' do
      md_wrap_xml_data_elements = @ac_mets_file.md_wrap_xml_data_elements
      expect(md_wrap_xml_data_elements.length).to eq(1)
      expect(md_wrap_xml_data_elements.first.name).to eq('xmlData')
    end
  end

  describe 'after parsing' do
    before(:context) do
      @ac_mets_file = described_class.new(file_fixture('xml/mets/AC_mets.xml').read)
      @ac_mets_file.parse
    end

    it 'sets the abstract correctly' do
      expect(@ac_mets_file.abstract).to include('originally published in The Book of Zloczew')
    end

    it 'sets the authors correctly' do
      expect(@ac_mets_file.authors).to include('Force, Pierre')
    end

    it 'sets the license uri correctly' do
      expect(@ac_mets_file.license_uri).to include('creativecommons.org/licenses/by/4.0')
    end

    it 'sets the note (type: internal) correctly' do
      expect(@ac_mets_file.note_internal).to include('by publisher - article appears')
    end

    it 'sets the title correctly' do
      expect(@ac_mets_file.title).to include('Gita May: A Life')
    end

    it 'sets the use and reproduction URI correctly' do
      expect(@ac_mets_file.use_and_reproduction_uri).to include('rightsstatements.org/vocab/InC/1.')
    end
  end
end
