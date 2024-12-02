# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositsController do
  describe 'get_endpoints' do
    it 'returns a ProquestEndpoint for given args' do
      endpoint = controller.get_endpoint('test-pq', 'firsttestdepositor')
      expect(endpoint).to be_a(Sword::Endpoints::ProquestEndpoint)
    end
  end
end
