require 'rails_helper'

RSpec.describe 'Sword request', type: :request do
  describe 'GET /sword/servicedocument' do
    before do
      user = User.find_by(email: 'user@example.org') ||
             User.create!(email: 'user@example.org', password: 'very-secret')
      allow(user).to receive(:admin?).and_return(true)
      sign_in user
      allow_any_instance_of(SwordController).to receive(:check_basic_http_authentication).and_return(true)
    end

    it 'returns HTTP status code found and response contains sword version' do
      get '/sword/servicedocument'
      expect(response.status).to eq(200)
      expect(response.body).to include('<sword:version>1.3</sword:version>')
    end
  end

  describe 'POST /sword/deposit' do
    before do
      user = User.find_by(email: 'user@example.org') ||
             User.create!(email: 'user@example.org', password: 'very-secret')
      allow(user).to receive(:admin?).and_return(true)
      sign_in user
      allow(Sword::Utils::Logging).to receive(:log_received_deposit_post)
      allow(Sword::Utils::Logging).to receive(:log_deposit_result_info)
      allow(Sword::Utils::Sword).to receive(:create_deposit)
      allow(Sword::Util).to receive(:unzip_deposit_file)
      allow_any_instance_of(Sword::Endpoints::AcademicCommonsEndpoint).to receive(:handle_deposit)
      allow_any_instance_of(Sword::Endpoints::AcademicCommonsEndpoint).to receive(:confirm_ingest).and_return(true)
      allow(Rails.logger).to receive(:warn)
    end

    context 'with valid collection slug and authentication' do
      it 'returns HTTP status code 201' do
        # Basic Authentication for firsttestdepositor, firstdepositorpasswd
        encoded_string = Base64.encode64('firsttestdepositor:firstdepositorpasswd')
        headers = { 'AUTHORIZATION' => "Basic #{encoded_string}",
                    'CONTENT_TYPE' => 'application/zip' }
        post '/sword/deposit/test-ac', headers: headers
        expect(response.status).to eq(201)
      end
    end

    context 'with invalid collection slug' do
      it 'returns HTTP status code 511' do
        # Basic Authentication for firsttestdepositor, firstdepositorpasswd
        encoded_string = Base64.encode64('firsttestdepositor:firstdepositorpasswd')
        headers = { 'AUTHORIZATION' => "Basic #{encoded_string}",
                    'CONTENT_TYPE' => 'application/zip' }
        expect(Rails.logger).to receive(:warn)
        post '/sword/deposit/test-invalid', headers: headers
        expect(response.status).to eq(400)
      end
    end

    context 'with valid collection slug, BUT invalid user' do
      it 'returns HTTP status code 511' do
        # Basic Authentication for invalidtestdepositor, invaliddepositorpasswd
        encoded_string = Base64.encode64('invalidtestdepositor:invaliddepositorpasswd')
        headers = { 'AUTHORIZATION' => "Basic #{encoded_string}",
                    'CONTENT_TYPE' => 'application/zip' }
        expect(Rails.logger).to receive(:warn)
        post '/sword/deposit/test-ac', headers: headers
        expect(response.status).to eq(511)
      end
    end

    context 'with valid collection slug, valid user BUT invalid password' do
      it 'returns HTTP status code 511' do
        # Basic Authentication for firsttestdepositor, invaliddepositorpasswd
        encoded_string = Base64.encode64('firsttestdepositor:invaliddepositorpasswd')
        headers = { 'AUTHORIZATION' => "Basic #{encoded_string}",
                    'CONTENT_TYPE' => 'application/zip' }
        expect(Rails.logger).to receive(:warn)
        post '/sword/deposit/test-ac', headers: headers
        expect(response.status).to eq(511)
      end
    end

    context 'with valid collection slug, valid authentication, but user no privs on collection' do
      it 'returns HTTP status code 511' do
        # Basic Authentication for secondtestdepositor, seconddepositorpasswd
        encoded_string = Base64.encode64('secondtestdepositor:seconddepositorpasswd')
        headers = { 'AUTHORIZATION' => "Basic #{encoded_string}",
                    'CONTENT_TYPE' => 'application/zip' }
        expect(Rails.logger).to receive(:warn)
        post '/sword/deposit/test-ac', headers: headers
        expect(response.status).to eq(400)
      end
    end
  end
end
