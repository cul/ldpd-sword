# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sword::Mets::ProquestEtdXmlDataElement do
  let(:pq_xml_data) { described_class.new(@xml_data_proquest, Sword::Mets::ProquestConstants::XPATH_INFO) }

  let(:author_attrs) { { first_name: 'Ariana', middle_name: 'Cecilia', last_name: 'Gavin', role: 'author' } }
  let(:expected_first_author) { Sword::Metadata::PersonalName.new(author_attrs) }

  let(:advisor_attrs) { { first_name: 'Henry', middle_name: 'M', last_name: 'Colecraft', role: 'advisor' } }
  let(:expected_first_advisor) { Sword::Metadata::PersonalName.new(advisor_attrs) }

  before(:context) do
    @pq_mets_file = Sword::Mets::MetsFile.new(file_fixture('xml/mets/PQ_mets.xml').read)
    # @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_elements(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
    @xml_data_proquest = @pq_mets_file.find_md_wrap_xml_data_element(mdtype: 'OTHER', other_mdtype: 'PROQUEST')
  end

  it 'sets the abstract correctly' do
    expect(pq_xml_data.abstract).to include('relief of Rad inhibition of cardiac')
  end

  it 'sets the title correctly' do
    expect(pq_xml_data.title).to include('Unraveling the logic')
  end

  it 'sets the subjects correctly' do
    expect(pq_xml_data.instance_variable_get(:@subjects)).to be_nil
    expect(pq_xml_data.subjects).to contain_exactly('Molecular biology', 'Pharmacology', 'Physiology')
  end

  it 'sets the authors correctly' do
    expect(pq_xml_data.instance_variable_get(:@authors)).to be_nil
    expect(pq_xml_data.authors.first.attributes).to eql(expected_first_author.attributes)
  end

  it 'sets the advisors correctly' do
    expect(pq_xml_data.advisors.first.attributes).to eql(expected_first_advisor.attributes)
  end
end
