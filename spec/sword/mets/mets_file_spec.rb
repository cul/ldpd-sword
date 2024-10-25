# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::MetsFile do
  describe 'at initialization' do
    before(:context) do
      @pq_mets_file = described_class.new(file_fixture('xml/mets/PQ_mets.xml').read)
      # @pq_mets_file = described_class.new(Nokogiri::XML(file_fixture('xml/mets/PQ_mets.xml').read))
    end

    it 'sets md_wrap_xml_data_elements correctly' do
      md_wrap_xml_data_elements = @pq_mets_file.md_wrap_xml_data_elements
      expect(md_wrap_xml_data_elements.length).to eq(2)
      expect(md_wrap_xml_data_elements.first.name).to eq('xmlData')
    end
  end

  describe 'find_md_wrap_xml_data_elements' do
    before(:context) do
      @pq_mets_file = described_class.new(file_fixture('xml/mets/PQ_mets.xml').read)
      # @pq_mets_file = described_class.new(Nokogiri::XML(file_fixture('xml/mets/PQ_mets.xml').read))
    end

    it 'works correctly for MDTYPE => OTHER and OTHERTYPE => PROQUEST' do
      xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
      expect(xml_data_proquest.length).to eq(1)
      expect(xml_data_proquest.first.name).to eq('xmlData')
    end
  end

  describe 'parse' do
    before(:context) do
      @pq_mets_file = described_class.new(file_fixture('xml/mets/PQ_mets.xml').read)
      @pq_mets_file.parse
    end

    it 'sets the file array corrently' do
      expect(@pq_mets_file.files).to include('Gavin_columbia_0054D_18819.pdf')
    end
  end
end
