require 'rails_helper'

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
end
