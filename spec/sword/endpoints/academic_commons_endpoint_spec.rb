require 'rails_helper'

require 'sword/endpoints/academic_commons_endpoint.rb'

RSpec.describe Sword::Endpoints::AcademicCommonsEndpoint do
  ########################################## hierarchy
  describe 'hierarchy' do
    it 'inherits from Endpoint' do
      expect(described_class.superclass).to eq(Sword::Endpoints::MetsToHyacinthEndpoint)
    end
  end

  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize' do
      it 'sets @mods_parser to a new instance of ModsParser' do
        expect(described_class.new('sample_collection_slug',
                                   'sample_depositor_user_id').mods_parser).to be_an_instance_of(Sword::Parsers::ModsParser)
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
        @ac_endpoint = Sword::Endpoints::AcademicCommonsEndpoint.new('test-ac',
                                                                     'firsttestdepositor')
        @content_dir = Rails.root.join 'spec/fixtures/test_dirs/ac_contents'
        # for test purposes, turn off actual sending of POST request
        @ac_endpoint.hyacinth_adapter.no_op_post = true
      end

      it 'calls the helper methods' do
        expect(@ac_endpoint).to receive(:process_metadata)
        expect(@ac_endpoint).to receive(:ingest_into_hyacinth)
        @ac_endpoint.handle_deposit @content_dir
      end
    end
  end

  ########################################## #process_doi_uri
  describe '#process_doi_uri' do
    before (:context) do
      @ac_endpoint = Sword::Endpoints::AcademicCommonsEndpoint.new('sample_collection_slug',
                                                                   'sample_depositor_user_id')
    end

    context 'given @mods_parser populated with just doi' do
      it 'info stored in @hyacinth_adapter is correct for doi' do
        @ac_endpoint.mods_parser.identifier_doi = 'doi:1234234'
        @ac_endpoint.process_doi_uri
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.parent_publication.doi).to eq('doi:1234234')
      end
    end

    context 'given @mods_parser populated with just uri' do
      it 'info stored in @hyacinth_adapter is correct for doi' do
        @ac_endpoint.mods_parser.identifier_uri = 'http://sampleuri'
        @ac_endpoint.process_doi_uri
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.parent_publication.uri).to eq('http://sampleuri')
      end
    end

    context 'given @mods_parser populated with doi and uri' do
      it 'info stored in @hyacinth_adapter is correct for doi' do
        @ac_endpoint.mods_parser.identifier_doi = 'doi:1234234'
        @ac_endpoint.mods_parser.identifier_uri = 'http://sampleuri'
        @ac_endpoint.process_doi_uri
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.parent_publication.doi).to eq('doi:1234234')
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.parent_publication.uri).to eq('http://sampleuri')
      end
    end
  end

  ########################################## #process_name_metadata
  describe '#process_name_metadata' do
    before (:context) do
      @ac_endpoint = Sword::Endpoints::AcademicCommonsEndpoint.new('sample_collection_slug',
                                                                   'sample_depositor_user_id')
      first_mods_name_personal = Sword::Metadata::ModsName.new
      first_mods_name_personal.name_part = 'Smith, John C.'
      first_mods_name_personal.type = 'personal'
      first_mods_name_personal.id = 'jcs1'
      second_mods_name_personal = Sword::Metadata::ModsName.new
      second_mods_name_personal.name_part = 'Doe, Jane A.'
      second_mods_name_personal.type = 'personal'
      second_mods_name_personal.id = 'jad1'
      @ac_endpoint.mods_parser.names << first_mods_name_personal
      @ac_endpoint.mods_parser.names << second_mods_name_personal
      @ac_endpoint.process_name_metadata
    end

    context 'given @mods_parser populated with 2 test individuals' do
      it 'info stored in @hyacinth_adapter is correct for first individual' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.personal_names.first.full_name_naf_format
              ).to eq('Smith, John C.')
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.personal_names.first.role).to eq('author')
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.personal_names.first.uni).to eq('jcs1')
      end

      it 'info stored in @hyacinth_adapter is correct for second individual' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.personal_names.second.full_name_naf_format
              ).to eq('Doe, Jane A.')
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.personal_names.second.role).to eq('author')
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.personal_names.second.uni).to eq('jad1')
      end
    end
  end

  ########################################## #process_metadata
  describe '#process_metadata' do
    before (:context) do
      @ac_endpoint = Sword::Endpoints::AcademicCommonsEndpoint.new('sample_collection_slug',
                                                                   'sample_depositor_user_id')
      @ac_endpoint.mods_parser.abstract = 'This is a sample terse abstract'
      @ac_endpoint.mods_parser.date_issued_start = '2015'
      @ac_endpoint.mods_parser.identifier_doi = 'doi:1234234'
      @ac_endpoint.mods_parser.identifier_uri = 'http://sampleuri'
      @ac_endpoint.mods_parser.note_internal = 'Sample note to catalogers.'
      @ac_endpoint.mods_parser.title = 'This is a Sample Title'
      @ac_endpoint.mods_parser.access_condition_use_and_reproduction_license_uri =
        'https://creativecommons.org/licenses/by/4.0/'
      @ac_endpoint.mods_parser.access_condition_use_and_reproduction_rights_status_uri =
        'http://rightsstatements.org/vocab/InC/1.0/'

      first_mods_name_personal = Sword::Metadata::ModsName.new
      first_mods_name_personal.name_part = 'Smith, John C.'
      first_mods_name_personal.type = 'personal'
      first_mods_name_personal.id = 'jcs1'
      second_mods_name_personal = Sword::Metadata::ModsName.new
      second_mods_name_personal.name_part = 'Doe, Jane A.'
      second_mods_name_personal.type = 'personal'
      second_mods_name_personal.id = 'jad1'
      @ac_endpoint.mods_parser.names << first_mods_name_personal
      @ac_endpoint.mods_parser.names << second_mods_name_personal

      @ac_endpoint.process_metadata
    end

    context 'given a populated ModsParser instance in @mods_parser' do
      it 'sets @hyacinth_adapter.encoder_item.abstract correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.abstract).to eq('This is a sample terse abstract')
      end

      it 'sets @hyacinth_adapter.encoder_item.date_issued_start correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.date_issued_start).to eq('2015')
      end

      it 'sets @hyacinth_adapter.encoder_item.parent_publication.doi correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.parent_publication.doi).to eq('doi:1234234')
      end

      it 'sets @hyacinth_adapter.encoder_item.parent_publication.uri correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.parent_publication.uri).to eq('http://sampleuri')
      end

      it 'sets @hyacinth_adapter.encoder_item.notes correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.notes.first.content).to eq('Sample note to catalogers.')
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.notes.first.type).to eq('internal')
      end

      it 'sets @hyacinth_adapter.encoder_item.title correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.title).to eq('This is a Sample Title')
      end

      it 'sets @hyacinth_adapter.encoder_item.license_uri correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.license_uri).to eq('https://creativecommons.org/licenses/by/4.0/')
      end

      it 'sets @hyacinth_adapter.encoder_item.use_and_reproduction_uri correctly' do
        expect(@ac_endpoint.hyacinth_adapter.encoder_item.use_and_reproduction_uri).to eq('http://rightsstatements.org/vocab/InC/1.0/')
      end
    end
  end
end
