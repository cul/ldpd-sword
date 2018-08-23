require 'rails_helper'

RSpec.describe Sword::Endpoints::SpringerNatureEndpoint do
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
        expect(described_class.new(Collection.new,
                                   Depositor.new).epdcx_parser).to be_an_instance_of(Sword::Parsers::EprintsDcXmlParser)
      end

      it 'sets @hyacinth_adapter to a new instance of HyacinthAdapter' do
        expect(described_class.new(Collection.new,
                                   Depositor.new).hyacinth_adapter).to be_an_instance_of(Sword::Adapters::HyacinthAdapter)
      end
    end
  end

  ########################################## #handle_deposit
  describe '#handle_deposit' do
    context 'given contents directory as its argument' do
      before(:context) do
        @springer_endpoint = Sword::Endpoints::SpringerNatureEndpoint.new(Collection.new,
                                                                     Depositor.new)
        @content_dir = Rails.root.join 'spec/fixtures/test_dirs/springer_nature_contents'
        # for test purposes, turn off actual sending of POST request
        @springer_endpoint.hyacinth_adapter.no_op_post = true
        @collection = Collection.new
        @depositor = Depositor.new
      end

      it '#handle_deposit is called successfully (without crashing)' do
        @springer_endpoint.handle_deposit(@content_dir)
      end
    end
  end

  ########################################## #process_name_metadata
  describe '#process_name_metadata' do
    before (:context) do
      @springer_endpoint = Sword::Endpoints::SpringerNatureEndpoint.new(Collection.new,
                                                                   Depositor.new)
      @springer_endpoint.epdcx_parser.creators << 'Smith, John C' << 'Doe, Jane A'
      @springer_endpoint.process_name_metadata
    end

    context 'given @epdcx_parser populated with 2 test individuals' do
      it 'info stored in @hyacinth_adapter is correct for first individual' do
        expect(@springer_endpoint.hyacinth_adapter.names.first.type).to eq('personal')
        expect(@springer_endpoint.hyacinth_adapter.names.first.full_name_naf_format
              ).to eq('Smith, John C')
        expect(@springer_endpoint.hyacinth_adapter.names.first.role).to eq('author')
      end

      it 'info stored in @hyacinth_adapter is correct for second individual' do
        expect(@springer_endpoint.hyacinth_adapter.names.second.type).to eq('personal')
        expect(@springer_endpoint.hyacinth_adapter.names.second.full_name_naf_format
              ).to eq('Doe, Jane A')
        expect(@springer_endpoint.hyacinth_adapter.names.second.role).to eq('author')
      end
    end
  end

  ########################################## #process_metadata
  describe '#process_metadata' do
    before (:context) do
      @springer_endpoint = Sword::Endpoints::SpringerNatureEndpoint.new(Collection.new,
                                                                   Depositor.new)
      @springer_endpoint.epdcx_parser.abstract = 'This is a sample terse abstract'
      @springer_endpoint.epdcx_parser.date_available = '2018-08-06'
      @springer_endpoint.epdcx_parser.identifier_uri = 'https://doi.org/10.1186/s13031-018-0173-x'
      @springer_endpoint.epdcx_parser.title = 'This is a Sample Title'
      @springer_endpoint.epdcx_parser.creators << 'Smith, John C' << 'Doe, Jane A'
      @springer_endpoint.epdcx_parser.subjects << 'Subject_one' << 'Subject_two'

      biblio_citation = Sword::Metadata::EpdcxBibliographicCitation.new
      biblio_citation.issue = '11'
      biblio_citation.publish_year = '2016'
      biblio_citation.start_page = '78'
      biblio_citation.title = 'International Journal of Stuff'
      biblio_citation.volume = '10'
      @springer_endpoint.epdcx_parser.bibliographic_citation = biblio_citation

      @springer_endpoint.process_metadata
    end

    context 'given a populated EprintsDcXmlParser instance in @epdcx_parser' do
      it 'sets @hyacinth_adapter.abstract correctly' do
        expect(@springer_endpoint.hyacinth_adapter.abstract).to eq('This is a sample terse abstract')
      end

      it 'sets @hyacinth_adapter.date_issued_start correctly' do
        expect(@springer_endpoint.hyacinth_adapter.date_issued_start).to eq('2018')
      end

      it 'sets @hyacinth_adapter.note_value correctly' do
        expect(@springer_endpoint.hyacinth_adapter.note_value).to eq('Subject_one, Subject_two')
      end

      it 'sets @hyacinth_adapter.title correctly' do
        expect(@springer_endpoint.hyacinth_adapter.title).to eq('This is a Sample Title')
      end

      context 'in @hyacinth_adapter.parent_publication' do
        it 'sets doi correctly' do
          expect(@springer_endpoint.hyacinth_adapter.parent_publication.doi).to eq('10.1186/s13031-018-0173-x')
        end

        it 'sets issue correctly' do
          expect(@springer_endpoint.hyacinth_adapter.parent_publication.issue).to eq('11')
        end

        it 'sets publish_date correctly' do
          expect(@springer_endpoint.hyacinth_adapter.parent_publication.publish_date).to eq('2016')
        end

        it 'sets start_page correctly' do
          expect(@springer_endpoint.hyacinth_adapter.parent_publication.start_page).to eq('78')
        end

        it 'sets title correctly' do
          expect(@springer_endpoint.hyacinth_adapter.parent_publication.title).to eq('International Journal of Stuff')
        end

        it 'sets volume correctly' do
          expect(@springer_endpoint.hyacinth_adapter.parent_publication.volume).to eq('10')
        end
      end
    end
  end
end
