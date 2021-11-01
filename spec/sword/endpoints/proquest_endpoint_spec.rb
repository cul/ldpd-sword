require 'rails_helper'

RSpec.describe Sword::Endpoints::ProquestEndpoint do
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
        expect(described_class.new(Collection.new,
                                   Depositor.new).proquest_etd_parser).to be_an_instance_of(Sword::Parsers::ProquestEtdParser)
      end

      it 'sets @hyacinth_adapter to a new instance of HyacinthAdapter' do
        expect(described_class.new(Collection.new,
                                   Depositor.new).hyacinth_adapter).to be_an_instance_of(Sword::Adapters::Hyacinth::V2::HyacinthAdapter)
      end
    end
  end

  ########################################## #handle_deposit
  describe '#handle_deposit' do
    context 'given a valid zipped file as its argument' do
      before(:context) do
        @proquest_endpoint = Sword::Endpoints::ProquestEndpoint.new('test-pq',
                                                                    'firsttestdepositor')
        @content_dir = Rails.root.join 'spec/fixtures/test_dirs/proquest_contents'
        # for test purposes, turn off actual sending of POST request
        @proquest_endpoint.hyacinth_adapter.no_op_post = true
      end

      it '#handle_deposit is called successfully (without crashing)' do
        @proquest_endpoint.handle_deposit(@content_dir)
      end
    end
  end

  ########################################## #process_degree_metadata
  describe '#process_degree_metadata' do
    before do
      @proquest_endpoint = Sword::Endpoints::ProquestEndpoint.new(Collection.new,
                                                                  Depositor.new)
      @proquest_endpoint.proquest_etd_parser.degree = 'Ph.D.'
      @proquest_endpoint.proquest_etd_parser.institution_department_name = 'History'
      @proquest_endpoint.process_degree_metadata
    end

    context 'given test metadata for degree-related info in @proquest_etd_parser' do
      it 'sets @hyacinth_adapter.degree correctly' do
        expect(@proquest_endpoint.hyacinth_adapter.degree.discipline).to eq('History')
        expect(@proquest_endpoint.hyacinth_adapter.degree.grantor).to eq('Columbia University')
        expect(@proquest_endpoint.hyacinth_adapter.degree.level).to eq('2')
        expect(@proquest_endpoint.hyacinth_adapter.degree.name).to eq('Ph.D.')
      end
    end
  end

  ########################################## #process_subject_metadata
  describe '#process_subject_metadata' do
    before do
      @proquest_endpoint = Sword::Endpoints::ProquestEndpoint.new(Collection.new,
                                                                  Depositor.new)
      @proquest_endpoint.proquest_etd_parser.subjects = ['Flux capacitor','Time travel']
      @proquest_endpoint.process_subject_metadata
    end

    context 'given test metadata for subject info in @proquest_etd_parser' do
      it 'sets @hyacinth_adapter.subjects correctly' do
        expect(@proquest_endpoint.hyacinth_adapter.subjects).to include *['Flux capacitor','Time travel']
      end
    end
  end

  ########################################## #process_name_metadata
  describe '#process_name_metadata' do
    before (:context) do
      @proquest_endpoint = Sword::Endpoints::ProquestEndpoint.new(Collection.new,
                                                                  Depositor.new)
      first_name_personal = Sword::Metadata::PersonalName.new
      first_name_personal.last_name = 'Smith'
      first_name_personal.first_name = 'John'
      first_name_personal.middle_name = 'C'
      first_name_personal.role = 'author'
      second_name_personal = Sword::Metadata::PersonalName.new
      second_name_personal.last_name = 'Doe'
      second_name_personal.first_name = 'Jane'
      second_name_personal.middle_name = 'A'
      second_name_personal.role = 'author'
      @proquest_endpoint.proquest_etd_parser.names << first_name_personal
      @proquest_endpoint.proquest_etd_parser.names << second_name_personal
      @proquest_endpoint.process_name_metadata
    end

    context 'given @proquest_etd_parser populated with 2 test individuals' do
      it 'info stored in @hyacinth_adapter is correct for first individual' do
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.last_name
              ).to eq('Smith')
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.first_name
              ).to eq('John')
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.middle_name
              ).to eq('C')
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.role).to eq('author')
      end

      it 'info stored in @hyacinth_adapter is correct for second individual' do
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.last_name
              ).to eq('Doe')
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.first_name
              ).to eq('Jane')
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.middle_name
              ).to eq('A')
        expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.role).to eq('author')
      end
    end
  end

  ########################################## #process_institution_info_into_corporate_name
  describe '#process_institution_info_into_corporate_name' do
    context 'given a skeletal ProquestEtdParser instance with just institution info in @proquest_etd_parser' do
      before (:example) do
        @proquest_endpoint = Sword::Endpoints::ProquestEndpoint.new(Collection.new,
                                                                    Depositor.new)
      end

      context "0054 and department name start with 'TC:'" do
        it "set corporate name correctly, and name type set to 'corporate'" do
          @proquest_endpoint.proquest_etd_parser.institution_department_name = 'TC: Science Education'
          @proquest_endpoint.proquest_etd_parser.institution_name = 'Columbia University'
          @proquest_endpoint.proquest_etd_parser.institution_school_code = '0054'
          @proquest_endpoint.process_institution_info_into_corporate_name
          expect(@proquest_endpoint.hyacinth_adapter.corporate_names.first.name
                ).to eq('Teachers College. Science Education')
        end
      end

      context "0054 and department name DOES NOTE start with 'TC:'" do
        it "set corporate name correctly, and name type set to 'corporate'" do
          @proquest_endpoint.proquest_etd_parser.institution_department_name = 'History'
          @proquest_endpoint.proquest_etd_parser.institution_name = 'Columbia University'
          @proquest_endpoint.proquest_etd_parser.institution_school_code = '0054'
          @proquest_endpoint.process_institution_info_into_corporate_name
          expect(@proquest_endpoint.hyacinth_adapter.corporate_names.first.name
                ).to eq('Columbia University. History')
        end
      end

      context "0055 (code for TC endpoint)" do
        it "set corporate name correctly, and name type set to 'corporate'" do
          @proquest_endpoint.proquest_etd_parser.institution_department_name = 'Health and Behavior Studies'
          @proquest_endpoint.proquest_etd_parser.institution_name = 'Teachers College, Columbia University'
          @proquest_endpoint.proquest_etd_parser.institution_school_code = '0055'
          @proquest_endpoint.process_institution_info_into_corporate_name
          expect(@proquest_endpoint.hyacinth_adapter.corporate_names.first.name
                ).to eq('Teachers College. Health and Behavior Studies')
        end
      end
    end
  end

  ########################################## #process_metadata
  describe '#process_metadata' do
    before (:context) do
      # TODO: corporate name, degree, etc.
      @proquest_endpoint = Sword::Endpoints::ProquestEndpoint.new(Collection.new,
                                                                  Depositor.new)
      @proquest_endpoint.proquest_etd_parser.abstract = 'This is a sample terse abstract'
      @proquest_endpoint.proquest_etd_parser.date_conferred = '2015'
      @proquest_endpoint.proquest_etd_parser.degree = 'Ph.D.'
      @proquest_endpoint.proquest_etd_parser.institution_department_name = 'Biological Sciences'
      @proquest_endpoint.proquest_etd_parser.institution_name = 'Columbia University'
      @proquest_endpoint.proquest_etd_parser.institution_school_code = '0054'
      @proquest_endpoint.proquest_etd_parser.title = 'This is a Sample Title'

      first_name_personal = Sword::Metadata::PersonalName.new
      first_name_personal.last_name = 'Smith'
      first_name_personal.first_name = 'John'
      first_name_personal.middle_name = 'C'
      first_name_personal.role = 'author'
      second_name_personal = Sword::Metadata::PersonalName.new
      second_name_personal.last_name = 'Doe'
      second_name_personal.first_name = 'Jane'
      second_name_personal.middle_name = 'A'
      second_name_personal.role = 'author'
      @proquest_endpoint.proquest_etd_parser.names << first_name_personal
      @proquest_endpoint.proquest_etd_parser.names << second_name_personal

      @proquest_endpoint.process_metadata
    end

    context 'given a populated ProquestEtdParser instance in @proquest_etd_parser' do
      context 'populated with 2 test individuals' do
        it 'info stored in @hyacinth_adapter is correct for first individual' do
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.last_name
                ).to eq('Smith')
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.first_name
                ).to eq('John')
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.middle_name
                ).to eq('C')
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.first.role).to eq('author')
        end

        it 'info stored in @hyacinth_adapter is correct for second individual' do
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.last_name
                ).to eq('Doe')
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.first_name
                ).to eq('Jane')
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.middle_name
                ).to eq('A')
          expect(@proquest_endpoint.hyacinth_adapter.personal_names.second.role).to eq('author')
        end
      end

      context 'populated with test document-specific metadata' do
        it 'sets @hyacinth_adapter.abstract correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.abstract).to eq('This is a sample terse abstract')
        end

        it 'sets @hyacinth_adapter.date_issued_start correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.date_issued_start).to eq('2015')
        end

        it 'sets @hyacinth_adapter.title correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.title).to eq('This is a Sample Title')
        end

      end

      context 'with unspecified values for the hard-coded data (since set in code)' do
        it 'sets @hyacinth_adapter.genre_value correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.genre_value).to eq(Sword::Constants::GENRE_TERM_VALUE_THESES)
        end

        it 'sets @hyacinth_adapter.genre_uri correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.genre_uri).to eq(Sword::Constants::GENRE_TERM_URI_THESES)
        end

        it 'sets @hyacinth_adapter.language_value correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.language_value).to eq(Sword::Constants::LANGUAGE_TERM_VALUE_ENGLISH)
        end

        it 'sets @hyacinth_adapter.language_uri correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.language_uri).to eq(Sword::Constants::LANGUAGE_TERM_URI_ENGLISH)
        end

        it 'sets @hyacinth_adapter.type_of_resource correctly' do
          expect(@proquest_endpoint.hyacinth_adapter.type_of_resource).to eq(Sword::Constants::TYPE_OF_RESOURCE_VALUE_TEXT)
        end
      end
    end
  end
end
