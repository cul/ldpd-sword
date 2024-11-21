# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositsController do
  describe 'get_endpoints' do
    it 'returns a ProquestEndpoint for given args' do
      endpoint = controller.get_endpoint('test-pq', 'firsttestdepositor')
      expect(endpoint).to be_a(Sword::Endpoints::ProquestEndpoint)
    end
  end

  describe 'resubmit' do
    before(:example) do
      the_endpoint = double("the_endpoint")
      allow(the_endpoint).to receive(:deposit_title) { "This is the title" }
      allow(the_endpoint).to receive(:handle_deposit) {['a.txt', 'b.txt'] }
      allow(the_endpoint).to receive(:documents_to_deposit) {['a.txt', 'b.txt'] }
      allow(the_endpoint).to receive(:adapter_item_identifier) { 'ac:12345678' }
      allow(the_endpoint).to receive(:asset_pids) { ['ac:10000000', 'ac:987654321'] }
      allow(the_endpoint).to receive(:confirm_ingest) { true }
      allow(controller).to receive(:get_endpoint) { the_endpoint }
      allow_any_instance_of(Sword::Endpoints::ProquestEndpoint).to receive(:handle_deposit).and_return(the_endpoint)
    end

    it 'creates new Deposit after re-ingest into Hyacinth' do
      deposit = create(:deposit)
      id = deposit.id
      allow(controller).to receive(:params).and_return( { id: 1 } )
      expect(Deposit.count).to eq(1)
      subject.resubmit
      expect(Deposit.count).to eq(2)
    end
  end
end
