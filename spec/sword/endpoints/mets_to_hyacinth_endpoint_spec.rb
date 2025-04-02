require 'rails_helper'

require 'sword/endpoints/mets_to_hyacinth_endpoint.rb'

RSpec.describe Sword::Endpoints::MetsToHyacinthEndpoint do
  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize' do
      it 'sets @mets_parser to a new instance of MetsParser' do
        expect(described_class.new('sample_collection_slug',
                                   'sample_depositor_user_id').mets_parser).to be_an_instance_of(Sword::Parsers::MetsParser)
      end
    end
  end

  describe '#handle_deposit' do
    context 'given a contents directory without a mets.xml file' do
      before(:context) do
        @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('sample_collection_slug',
                                                                      'sample_depositor_user_id')
      end

      it 'raises an error because no mets.xml file in given directory' do
        content_dir = Rails.root.join 'spec/fixtures/test_dirs/contents_dir_without_mets_file'
        expect { @mets_endpoint.handle_deposit(content_dir) }.to raise_error('mets.xml file missing')
      end
    end

    context 'given contents directory as its argument' do
      # add check here about calling @mets_parser.parse
    end
  end

  describe '#ingest_item_into_hyacinth' do
    context 'if ingest into Hyacinth is ' do
      before(:example) do
        @hyacinth_adapter_double = instance_double(Sword::Adapters::HyacinthAdapter)
        allow(Sword::Adapters::HyacinthAdapter).to receive(:new).and_return(@hyacinth_adapter_double)
        allow(@hyacinth_adapter_double).to receive(:hyacinth_project=)
        allow(@hyacinth_adapter_double).to receive(:deposited_by=)
        allow(@hyacinth_adapter_double).to receive(:compose_internal_format_item)
        allow(@hyacinth_adapter_double).to receive(:ingest_item)
        allow(@hyacinth_adapter_double).to receive(:pid_last_ingest).and_return('cul:123456')
        allow(@hyacinth_adapter_double).to receive(:no_op_post).and_return(true)
      end

      it 'successful, will get the pid from the Hyacinth adapter' do
        allow(@hyacinth_adapter_double).to receive(:last_ingest_successful?).and_return(true)
        @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('test-pq',
                                                                      'firsttestdepositor')
        expect(@hyacinth_adapter_double).to receive(:pid_last_ingest)
        @mets_endpoint.ingest_item_into_hyacinth
      end

      it 'unsuccessful, will not get the pid from the Hyacinth adapter' do
        allow(@hyacinth_adapter_double).to receive(:last_ingest_successful?).and_return(false)
        @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('test-pq',
                                                                      'firsttestdepositor')
        expect(@hyacinth_adapter_double).not_to receive(:pid_last_ingest)
        @mets_endpoint.ingest_item_into_hyacinth
      end

      it 'unsuccessful with no_op_post set to false' do
        allow(@hyacinth_adapter_double).to receive(:no_op_post).and_return(false)
        allow(@hyacinth_adapter_double).to receive(:last_ingest_successful?).and_return(false)
        @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('test-pq',
                                                                      'firsttestdepositor')
        expect(@hyacinth_adapter_double).not_to receive(:pid_last_ingest)
        @mets_endpoint.ingest_item_into_hyacinth
      end
    end
  end

  describe '#ingest_documents_into_hyacinth' do
    context 'given 2 document files ' do
      before(:example) do
        @hyacinth_adapter_double = instance_double(Sword::Adapters::HyacinthAdapter)
        allow(Sword::Adapters::HyacinthAdapter).to receive(:new).and_return(@hyacinth_adapter_double)
        allow(@hyacinth_adapter_double).to receive(:ingest_asset)
        @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('sample_collection_slug',
                                                                      'sample_depositor_user_id')
        @mets_endpoint.instance_variable_set(:@documents_to_deposit, ['first_file', 'second_file'])
        @mets_endpoint.instance_variable_set(:@content_dir, '/tmp/')
      end

      it 'it calls ingest_asset twice, once for each file' do
        expect(@hyacinth_adapter_double).to receive(:ingest_asset).twice
        @mets_endpoint.ingest_documents_into_hyacinth
      end
    end
  end

  describe '#ingest_mets_xml_file_into_hyacinth' do
    context 'given mets file ' do
      before(:example) do
        @hyacinth_adapter_double = instance_double(Sword::Adapters::HyacinthAdapter)
        allow(Sword::Adapters::HyacinthAdapter).to receive(:new).and_return(@hyacinth_adapter_double)
        allow(@hyacinth_adapter_double).to receive(:ingest_asset)
        @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('sample_collection_slug',
                                                                      'sample_depositor_user_id')
        @mets_endpoint.instance_variable_set(:@content_dir, '/tmp/')
        @mets_endpoint.instance_variable_set(:@pid_hyacinth_item_object, 'cul:123456789')
      end

      it 'it calls ingest_asset once' do
        expect(@hyacinth_adapter_double).to receive(:ingest_asset).once
        @mets_endpoint.ingest_mets_xml_file_into_hyacinth
      end
    end
  end

  describe 'confirm_ingest' do
    before(:example) do
      @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('sample_collection_slug',
                                                                    'sample_depositor_user_id')
      @hyacinth_adapter = double("hyacinth_adapter")
      @mets_endpoint.instance_variable_set(:@hyacinth_adapter, @hyacinth_adapter)
    end

    it 'returns false if expected_and_retrieved_asset_pids_match? returns false' do
      allow(@hyacinth_adapter).to receive(:expected_and_retrieved_asset_pids_match?) { false }
      expect(@mets_endpoint.confirm_ingest).to be(false)
    end

    it 'returns true if expected_and_retrieved_asset_pids_match? return true' do
      allow(@hyacinth_adapter).to receive(:expected_and_retrieved_asset_pids_match?) { true }
      expect(@mets_endpoint.confirm_ingest).to be(true)
    end
  end

  describe 'ingest_into_hyacinth' do
    before(:example) do
      @mets_endpoint = Sword::Endpoints::MetsToHyacinthEndpoint.new('sample_collection_slug',
                                                                    'sample_depositor_user_id')
      @hyacinth_adapter = double("hyacinth_adapter")
      @mets_endpoint.instance_variable_set(:@hyacinth_adapter, @hyacinth_adapter)
      allow(@hyacinth_adapter).to receive(:asset_pids) { ['asdasda', 'qweqweqwe'] }
      allow(@mets_endpoint).to receive(:ingest_item_into_hyacinth)
      allow(@mets_endpoint).to receive(:ingest_documents_into_hyacinth)
      allow(@mets_endpoint).to receive(:ingest_mets_xml_file_into_hyacinth)
    end

    it 'calls expected methods' do
      allow(@mets_endpoint).to receive(:bypass_ingest_into_hyacinth?) { false }
      expect(@mets_endpoint).to receive(:ingest_item_into_hyacinth)
      expect(@mets_endpoint).to receive(:ingest_documents_into_hyacinth)
      expect(@mets_endpoint).to receive(:ingest_mets_xml_file_into_hyacinth)
      @mets_endpoint.ingest_into_hyacinth
    end

    it 'set @adapter_item_identifier to default if bypass hyacinth ingest is true' do
      allow(@mets_endpoint).to receive(:bypass_ingest_into_hyacinth?) { true }
      @mets_endpoint.ingest_into_hyacinth
      # expect(@mets_endpoint).to receive(:ingest_item_into_hyacinth)
      expect(@mets_endpoint.adapter_item_identifier).to eq('na:xxxxxxxxxxx')
    end
  end
end
