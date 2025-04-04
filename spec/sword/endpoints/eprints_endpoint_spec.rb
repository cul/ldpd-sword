require 'rails_helper'

require 'sword/endpoints/eprints_endpoint.rb'

RSpec.describe Sword::Endpoints::EprintsEndpoint do
  ########################################## hierarchy
  describe 'hierarchy' do
    it 'inherits from Endpoint' do
      expect(described_class.superclass).to eq(Sword::Endpoints::MetsToHyacinthEndpoint)
    end
  end

  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize' do
      it 'sets @epdcx_parser to a new instance of EprintsDcXmlParser' do
        expect(described_class.new('sample_collection_slug',
                                   'sample_depositor_user_id').epdcx_parser).to be_an_instance_of(Sword::Parsers::EprintsDcXmlParser)
      end

      it 'sets @hyacinth_adapter to a new instance of HyacinthAdapter' do
        expect(described_class.new('sample_collection_slug',
                                   'sample_depositor_user_id').hyacinth_adapter).to be_an_instance_of(Sword::Adapters::HyacinthAdapter)
      end
    end
  end

  ########################################## #handle_deposit
  describe '#handle_deposit' do
    context 'given contents directory as its argument' do
      before(:context) do
        @eprints_endpoint = Sword::Endpoints::EprintsEndpoint.new('test-sn',
                                                                  'firsttestdepositor')
        @content_dir = Rails.root.join 'spec/fixtures/test_dirs/springer_nature_contents'
        # for test purposes, turn off actual sending of POST request
        @eprints_endpoint.hyacinth_adapter.no_op_post = true
      end

      it 'calls the helper methods' do
        expect(@eprints_endpoint).to receive(:process_metadata)
        expect(@eprints_endpoint).to receive(:ingest_into_hyacinth)
        @eprints_endpoint.handle_deposit @content_dir
      end
    end
  end

  ########################################## #process_name_metadata
  describe '#process_name_metadata' do
    before (:context) do
      @eprints_endpoint = Sword::Endpoints::EprintsEndpoint.new('sample_collection_slug',
                                                                'sample_depositor_user_id')
      @eprints_endpoint.epdcx_parser.creators << 'Smith, John C' << 'Doe, Jane A'
      @eprints_endpoint.process_name_metadata
    end

    context 'given @epdcx_parser populated with 2 test individuals' do
      it 'info stored in @hyacinth_adapter is correct for first individual' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.personal_names.first.full_name_naf_format
              ).to eq('Smith, John C')
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.personal_names.first.role).to eq('author')
      end

      it 'info stored in @hyacinth_adapter is correct for second individual' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.personal_names.second.full_name_naf_format
              ).to eq('Doe, Jane A')
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.personal_names.second.role).to eq('author')
      end
    end
  end

  ########################################## #process_metadata
  describe '#process_metadata' do
    before (:context) do
      @eprints_endpoint = Sword::Endpoints::EprintsEndpoint.new('sample_collection_slug',
                                                                'sample_depositor_user_id')
      @eprints_endpoint.epdcx_parser.abstract = 'This is a sample terse abstract'
      @eprints_endpoint.epdcx_parser.date_available = '2018-08-06'
      @eprints_endpoint.epdcx_parser.identifier = 'https://doi.org/10.1186/s13031-018-0173-x'
      @eprints_endpoint.epdcx_parser.title = 'This is a Sample Title'
      @eprints_endpoint.epdcx_parser.creators << 'Smith, John C' << 'Doe, Jane A'
      @eprints_endpoint.epdcx_parser.subjects << 'Subject_one' << 'Subject_two'

      biblio_citation = Sword::Metadata::EpdcxBibliographicCitation.new
      biblio_citation.issue = '11'
      biblio_citation.publish_year = '2016'
      biblio_citation.start_page = '78'
      biblio_citation.title = 'International Journal of Stuff'
      biblio_citation.volume = '10'
      @eprints_endpoint.epdcx_parser.bibliographic_citation = biblio_citation
      @eprints_endpoint.emails = ["theuser@example.com", "theotheruser@example.com"]
      @eprints_endpoint.process_metadata
    end

    context 'given a populated EprintsDcXmlParser instance in @epdcx_parser' do
      it 'sets @hyacinth_adapter.encoder_item.abstract correctly' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.abstract).to eq('This is a sample terse abstract')
      end

      it 'sets @hyacinth_adapter.encoder_item.date_issued_start correctly' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.date_issued_start).to eq('2018')
      end

      it 'sets @hyacinth_adapter.encoder_item.notes correctly' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.notes.first).to be_a Sword::Metadata::Note
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.notes.first.content).to eq('Subject_one, Subject_two')
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.notes.first.type).to be nil
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.notes[1]).to be_a Sword::Metadata::Note
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.notes[1].content).to eq('theuser@example.com, theotheruser@example.com')
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.notes[1].type).to be nil
      end

      it 'sets @hyacinth_adapter.encoder_item.title correctly' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.title).to eq('This is a Sample Title')
      end

      context 'in @hyacinth_adapter.encoder_item.parent_publication' do
        it 'sets doi correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.doi).to eq('10.1186/s13031-018-0173-x')
        end

        it 'sets issue correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.issue).to eq('11')
        end

        it 'sets publish_date correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.publish_date).to eq('2016')
        end

        it 'sets start_page correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.start_page).to eq('78')
        end

        it 'sets title correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.title).to eq('International Journal of Stuff')
        end

        it 'sets volume correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.volume).to eq('10')
        end
      end
    end
  end

  ########################################## #process_metadata, no bibliographic citation
  describe '#process_metadata still set parent publication date and title' do
    before (:context) do
      @eprints_endpoint = Sword::Endpoints::EprintsEndpoint.new('sample_collection_slug',
                                                                'sample_depositor_user_id')
      @eprints_endpoint.epdcx_parser.date_available = '2018-08-06'
      @eprints_endpoint.epdcx_parser.publisher = 'The Good Journal'

      @eprints_endpoint.process_metadata
    end

    context 'given a populated EprintsDcXmlParser instance in @epdcx_parser without bibliographic citation' do
      it 'sets @hyacinth_adapter.encoder_item.date_issued_start correctly' do
        expect(@eprints_endpoint.hyacinth_adapter.encoder_item.date_issued_start).to eq('2018')
      end

      context 'in @hyacinth_adapter.encoder_item.parent_publication' do
        it 'sets doi correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.doi).to eq(nil)
        end

        it 'sets issue correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.issue).to eq(nil)
        end

        it 'sets publish_date correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.publish_date).to eq('2018')
        end

        it 'sets start_page correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.start_page).to eq(nil)
        end

        it 'sets title correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.title).to eq('The Good Journal')
        end

        it 'sets volume correctly' do
          expect(@eprints_endpoint.hyacinth_adapter.encoder_item.parent_publication.volume).to eq(nil)
        end
      end
    end
  end
end
