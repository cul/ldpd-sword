# require 'rails_helper'

RSpec.describe Sword::Utils::Deposits do
  describe 'resubmit_deposit' do
    before(:example) do
      @deposit = Deposit.new
      @deposit.depositor_user_id = 'test_depositor',
      @deposit.collection_slug = 'test_collection_slug',
      @deposit.deposit_files = ['a.txt','b.txt'],
      @deposit.title = 'The test title',
      @deposit.item_in_hyacinth = 'ac:12345',
      @deposit.asset_pids = ['ac:54321', 'ac:0984'],
      @deposit.ingest_confirmed = true,
      @deposit.content_path = 'tmp/somewhere/'
      @deposit.save
      @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('test-pq',
                                                                    'firsttestdepositor')
      allow(@mets_endpoint).to receive(:handle_deposit)
      allow(@mets_endpoint).to receive(:confirm_ingest) { true }
      @mets_endpoint.instance_variable_set(:@deposit_title, 'This is the title')
      @mets_endpoint.instance_variable_set(:@documents_to_deposit, ['first_file', 'second_file'])
      @mets_endpoint.instance_variable_set(:@adapter_item_identifier, 'cul:123456789')
      @mets_endpoint.instance_variable_set(:@asset_pids, ['ac:123456789'])
      allow(Sword::Endpoints::Endpoint).to receive(:get_endpoint) { @mets_endpoint }
    end

    it 'calls handle_deposit' do
      expect(@mets_endpoint).to receive(:handle_deposit)
      described_class.resubmit_deposit(@deposit)
    end
  end
end
