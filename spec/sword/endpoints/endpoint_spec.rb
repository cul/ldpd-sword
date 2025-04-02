require 'rails_helper'

RSpec.describe Sword::Endpoints::Endpoint do
  describe 'get_endpoint' do
    it 'instantiates ProQuest endpoint' do
      endpoint = described_class.get_endpoint('test-pq','test_depositor')
      expect(endpoint).to be_a_kind_of(Sword::Endpoints::ProquestEndpoint)
    end

    it 'instantiates AC endpoint' do
      endpoint = described_class.get_endpoint('test-ac','test_depositor')
      expect(endpoint).to be_a_kind_of(Sword::Endpoints::AcademicCommonsEndpoint)
    end

    it 'instantiates EPrints endpoint' do
      endpoint = described_class.get_endpoint('test-sn','test_depositor')
      expect(endpoint).to be_a_kind_of(Sword::Endpoints::EprintsEndpoint)
    end

    it 'raises exception if undefined endpoint' do
      expect { described_class.get_endpoint('test-slug','firsttestdepositor') }.to raise_error(/No endpoint/)
    end
  end
end
