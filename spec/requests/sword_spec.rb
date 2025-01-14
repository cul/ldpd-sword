require "rails_helper"

RSpec.describe "Sword request", type: :request do
  context 'POST /sword/deposit/:collection_slug' do
    xit 'returns HTTP status code found' do
      expect(response.status).to eq(201)
    end
  end
end
