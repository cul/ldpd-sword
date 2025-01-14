require 'rails_helper'

class DummyClass
  include SwordHelper
end

RSpec.describe SwordHelper do
  describe 'collection_info_for_service_document' do
    it 'contains expected values' do
      dc = DummyClass.new
      info = dc.collection_info_for_service_document('test-pq')
      expect(info).to have_key(:slug)
    end
  end

  describe 'pull_credentials' do
    it 'returns array with Basic auth info' do
      dc = DummyClass.new
      encoded_auth = 'Basic Zmlyc3R0ZXN0ZGVwb3NpdG9yOmZpcnN0ZGVwb3NpdG9ycGFzc3dk'
      request_double = instance_double(ActionDispatch::Request)
      allow(request_double).to receive(:headers).and_return({'Authorization' => encoded_auth})
      depositor, passwd = dc.pull_credentials request_double
      expect(depositor).to eq('firsttestdepositor')
      expect(passwd).to eq('firstdepositorpasswd')
    end
  end

  describe 'create_deposit' do
    it 'returns service document content' do
      dc = DummyClass.new
      deposit = create_deposit('test_user',
                               'test_collection_slug',
                               ['a.txt','b.txt'],
                               'The test title',
                               'ac:12345',
                               ['ac:54321', 'ac:0984'],
                               true,
                               'tmp/somewhere/')
      expect(deposit).to be_an_instance_of(Deposit)
      end
  end

  describe 'service_document_content' do
    context 'with config info' do
      it 'returns service document content' do
        dc = DummyClass.new
        expect(dc.service_document_content).to include 'sword_version'
      end
    end
  end

  describe 'service_document_xml' do
    context 'with mime type and package type specified' do
      it 'returns' do
        dc = DummyClass.new
        content = HashWithIndifferentAccess.new
        info = HashWithIndifferentAccess.new
        info[:atom_title] = 'Atom Title of Proquest Test Collection'
        info[:slug] = 'test-pq'
        info[:mime_types] = ['a-type']
        info[:sword_package_types] = ['a-package-type']
        info[:abstract] = nil
        info[:mediation_enabled] = false
        content[:collections] = [info]
        content[:sword_version] = 1.3
        content[:sword_verbose] = false
        content[:http_host] = 'something'
        expect(dc.service_document_xml(content)).to include 'a-package-type'
      end
    end

    context 'without mime type and package type specified' do
      it 'returns' do
        dc = DummyClass.new
        content = HashWithIndifferentAccess.new
        info = HashWithIndifferentAccess.new
        info[:atom_title] = 'Atom Title of Proquest Test Collection'
        info[:slug] = 'test-pq'
        info[:mime_types] = nil
        info[:sword_package_types] = nil
        info[:abstract] = nil
        info[:mediation_enabled] = false
        content[:collections] = [info]
        content[:sword_version] = 1.3
        content[:sword_verbose] = false
        content[:http_host] = 'something'
        expect(dc.service_document_xml(content)).to include 'Title of Proquest Test'
      end
    end
  end
end
