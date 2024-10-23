# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::XmlDataElement do
  describe 'initialize pq data and after parse' do
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
end
