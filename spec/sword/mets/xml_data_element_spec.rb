# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::XmlDataElement do
  describe 'at initialization' do
    before(:context) do
      @pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
      # @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
      @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    end

    let(:pq_xml_data) { described_class.new(@xml_data_proquest, Sword::Mets::ProquestConstants::XPATH_INFO) }

    it 'sets the abstract correctly' do
      expect(pq_xml_data.abstract).to include('relief of Rad inhibition of cardiac')
    end

    it 'sets the title correctly' do
      expect(pq_xml_data.title).to include('Unraveling the logic')
    end
  end
end
