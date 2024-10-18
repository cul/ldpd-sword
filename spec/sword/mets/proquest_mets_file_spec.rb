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

    it 'sets the title correctly' do
      expect(@pq_mets_file.title).to include('Unraveling the logic')
    end

    it 'sets the abstract correctly' do
      expect(@pq_mets_file.abstract).to include('relief of Rad inhibition of cardiac')
    end
  end
end
