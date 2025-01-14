require "rails_helper"

RSpec.describe "Deposits request", type: :request do
  context 'GET /deposit' do
    xit 'returns HTTP status code found' do
      get '/deposits'
      expect(response.status).to eq(200)
    end
  end

  context 'GET /deposit/:index' do
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
    end
    
    xit 'returns HTTP status code found' do
      id = Deposit.all.first.id
      get "/deposits/#{id}"
      expect(response.status).to eq(200)
    end
  end

  context 'DELETE /deposit/:index' do
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
    end
    
    xit 'returns HTTP status code found' do
      expect(Deposit.all.count).to eq(1)
      id = Deposit.all.first.id
      delete "/deposits/#{id}"
      expect(Deposit.all.count).to eq(0)
    end
  end
end
