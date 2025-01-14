require 'rails_helper'

require 'sword/adapters/hyacinth_adapter.rb'

RSpec.describe Sword::Adapters::HyacinthAdapter do
  ########################################## Initial state
  describe 'Initial state' do
    context '#initialize' do
      it 'sets @dynamic_field_data to a new empty Hash' do
        expect(described_class.new.dynamic_field_data).to be_an_instance_of(Hash)
        expect(described_class.new.dynamic_field_data).to be_empty
      end

      it 'sets @corporate_names to a new empty Array' do
        expect(described_class.new.corporate_names).to be_an_instance_of(Array)
        expect(described_class.new.corporate_names).to be_empty
      end

      it 'sets @personal_names to a new empty Array' do
        expect(described_class.new.personal_names).to be_an_instance_of(Array)
        expect(described_class.new.personal_names).to be_empty
      end

      it 'sets @subject to a new empty Array' do
        expect(described_class.new.subjects).to be_an_instance_of(Array)
        expect(described_class.new.subjects).to be_empty
      end
    end
  end

  ########################################## encoding methods functionality specs
  describe 'encode methods' do
    hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new

    ########################################## #encode_abstract
    describe '#encode_abstract' do
      context 'given @abstract set to a given value' do
        expected_value = [ { abstract_value: 'This is a sample abstract' } ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.abstract = 'This is a sample abstract'
          hyacinth_adapter.encode_abstract
          expect(hyacinth_adapter.dynamic_field_data[:abstract]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_date_issued
    describe '#encode_date_issued' do
      context 'given @date_issued set to a given value' do
        expected_value = [ { date_issued_start_value: 2015 } ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.date_issued_start = 2015
          hyacinth_adapter.encode_date_issued
          expect(hyacinth_adapter.dynamic_field_data[:date_issued]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_degree
    describe '#encode_degree' do
      context 'given @degree set to a given test value' do
        expected_value = [ { degree_name: 'Ph.D',
                             degree_level: 2,
                             degree_discipline: 'Microbiology, Immunology and Infection',
                             degree_grantor: 'Columbia University'
                           } ]
        it 'constructs correct encoded format' do
          degree = Sword::Metadata::Degree.new
          degree.discipline = 'Microbiology, Immunology and Infection'
          degree.grantor = 'Columbia University'
          degree.level = 2
          degree.name = 'Ph.D'
          hyacinth_adapter.degree = degree
          hyacinth_adapter.encode_degree
          expect(hyacinth_adapter.dynamic_field_data[:degree]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_deposited_by
    describe '#encode_deposited_by' do
      context 'given @deposited_by set to a given value' do
        expected_value = [ { deposited_by_value: 'First Test Depositor' } ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.deposited_by = 'First Test Depositor'
          hyacinth_adapter.encode_deposited_by
          expect(hyacinth_adapter.dynamic_field_data[:deposited_by]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_embargo_release_date
    describe '#encode_embargo_release_date' do
      context 'given @embargo_release_date set to a given value' do
        expected_value = [ { embargo_release_date_value: '2015' } ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.embargo_release_date = '2015'
          hyacinth_adapter.encode_embargo_release_date
          expect(hyacinth_adapter.dynamic_field_data[:embargo_release_date]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_genre
    describe '#encode_genre' do
      context 'given @genre_uri and @genre_value set to a given value' do
        expected_value = [ { genre_term:
                               { value: "articles",
                                 uri: "http://vocab.getty.edu/aat/300048715"
                               }
                           }
                         ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.genre_uri = 'http://vocab.getty.edu/aat/300048715'
          hyacinth_adapter.genre_value = 'articles'
          hyacinth_adapter.encode_genre
          expect(hyacinth_adapter.dynamic_field_data[:genre]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_language
    describe '#encode_language' do
      context 'given @language_uri and @language_value set to a given value' do
        expected_value = [ { language_term:
                               { value: "English",
                                 uri: "http://id.loc.gov/vocabulary/iso639-2/eng"
                               }
                           }
                         ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.language_uri = 'http://id.loc.gov/vocabulary/iso639-2/eng'
          hyacinth_adapter.language_value = 'English'
          hyacinth_adapter.encode_language
          expect(hyacinth_adapter.dynamic_field_data[:language]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_license
    describe '#encode_license' do
      context 'given @license_uri sset to a given value' do
        expected_value = [ { license_term:
                               { uri: "https://creativecommons.org/licenses/by/4.0/"
                               }
                           }
                         ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.license_uri = 'https://creativecommons.org/licenses/by/4.0/'
          hyacinth_adapter.encode_license
          expect(hyacinth_adapter.dynamic_field_data[:license]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_names
    describe '#encode_names' do
      context 'given @personalnames and @corporate_names set to a given values' do
        expected_value =
          [
	    {
	      name_term:
	       {
		 value: 'Columbia University. Microbiology, Immunology and Infection',
		 name_type: "corporate"
	       },
	      name_role:
	        [
		  {
		    name_role_term:
		      {
			uri: "http://id.loc.gov/vocabulary/relators/org",
			value: "Originator"
		      }
		  }
	        ]
	    },
	    {
              name_term:
                {
                  value: "Smith, John Howard",
                  name_type: "personal"
                },
              name_role:
                [
                  {
                    name_role_term:
                      {
                        uri: "http://id.loc.gov/vocabulary/relators/aut",
                        value: "Author"
                      }
                  }
                ]
            },
	    {
              name_term:
                {
                  value: "Smithy, Johny Howardy",
                  name_type: "personal"
                },
              name_role:
                [
                  {
                    name_role_term:
                      {
                        uri: "http://id.loc.gov/vocabulary/relators/ths",
                        value: "Thesis advisor"
                      }
                  }
                ]
            }
          ]
        it 'constructs correct encoded format' do
          corporate_name = Sword::Metadata::CorporateName.new
          corporate_name.name = 'Columbia University. Microbiology, Immunology and Infection'
          corporate_name.role = 'originator'
          hyacinth_adapter.corporate_names << corporate_name

          first_personal_name = Sword::Metadata::PersonalName.new
          first_personal_name.full_name_naf_format = 'Smith, John Howard'
          first_personal_name.role = 'author'
          hyacinth_adapter.personal_names << first_personal_name

          second_personal_name = Sword::Metadata::PersonalName.new
          second_personal_name.full_name_naf_format = 'Smithy, Johny Howardy'
          second_personal_name.role = 'thesis_advisor'
          hyacinth_adapter.personal_names << second_personal_name

          hyacinth_adapter.encode_names
          expect(hyacinth_adapter.dynamic_field_data[:name]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_notes
    describe '#encode_notes' do
      context 'given @notes set to given test values' do
        expected_value = [ { note_value: 'Copyright: 2016 Hyacinth Composer',
                             note_type: 'internal' },
                           { note_value: 'Another note without a type' }
                         ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.notes = []
          hyacinth_adapter.notes << Sword::Metadata::Note.new('Copyright: 2016 Hyacinth Composer', 'internal')
          hyacinth_adapter.notes << Sword::Metadata::Note.new('Another note without a type')
          hyacinth_adapter.encode_notes
          expect(hyacinth_adapter.dynamic_field_data[:note]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_parent_publication
    describe '#encode_parent_publication' do
      context 'given @parent_publication set to a given test value' do
        expected_value =
          [
            {
              parent_publication_title:
                [
                  {
                    parent_publication_title_non_sort_portion: nil,
		    parent_publication_title_sort_portion: 'International Journal of Stuff'
                  }
	        ],
              parent_publication_date_created_textual: 2016,
              parent_publication_volume: 10,
              parent_publication_issue: 11,
              parent_publication_page_start: 78,
              parent_publication_doi: "10.1186/s13033-015-0032-8",
              parent_publication_uri: "https://doi.org"
            }
          ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.parent_publication =
            Sword::Metadata::ParentPublication.new
          hyacinth_adapter.parent_publication.title = 'International Journal of Stuff'
          hyacinth_adapter.parent_publication.publish_date = 2016
          hyacinth_adapter.parent_publication.volume = 10
          hyacinth_adapter.parent_publication.issue = 11
          hyacinth_adapter.parent_publication.start_page = 78
          hyacinth_adapter.parent_publication.doi = "10.1186/s13033-015-0032-8"
          hyacinth_adapter.parent_publication.uri = "https://doi.org"
          hyacinth_adapter.encode_parent_publication
          expect(hyacinth_adapter.dynamic_field_data[:parent_publication]).to eq(expected_value)
        end
      end

      context 'given @parent_publication with just the title set' do
        expected_value =
          [
            {
              parent_publication_title:
                [
                  {
                    parent_publication_title_non_sort_portion: nil,
		    parent_publication_title_sort_portion: 'International Journal of Stuff'
                  }
	        ]
            }
          ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.parent_publication =
            Sword::Metadata::ParentPublication.new
          hyacinth_adapter.parent_publication.title = 'International Journal of Stuff'
          hyacinth_adapter.encode_parent_publication
          expect(hyacinth_adapter.dynamic_field_data[:parent_publication]).to eq(expected_value)
        end
      end

      context 'given @parent_publication with just the DOI set' do
        expected_value =
          [
            {
              parent_publication_doi: "10.1186/s13033-015-0032-8"
            }
          ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.parent_publication =
            Sword::Metadata::ParentPublication.new
          hyacinth_adapter.parent_publication.doi = "10.1186/s13033-015-0032-8"
          hyacinth_adapter.encode_parent_publication
          expect(hyacinth_adapter.dynamic_field_data[:parent_publication]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_subjects
    describe '#encode_subjects' do
      context 'given a populated @subjects (which is an array) with test data'  do
        expected_value_topic =
          [
	    {
	      subject_topic_term:
	       {
		 value: "Caribbean literature",
		 uri: "http://id.worldcat.org/fast/847469"
	       }
	    }
          ]
        expected_value_geographic =
          [
	    {
	      subject_geographic_term:
	        {
		 value: "Caribbean Area",
		 uri: "http://id.worldcat.org/fast/1244080"
	       }
	    }
          ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.subjects << 'caribbean studies'
          hyacinth_adapter.subjects << 'caribbean literature'
          hyacinth_adapter.encode_subjects
          expect(hyacinth_adapter.dynamic_field_data[:subject_topic]).to eq(expected_value_topic)
          expect(hyacinth_adapter.dynamic_field_data[:subject_geographic]).to eq(expected_value_geographic)
        end
      end
    end

    ########################################## #encode_title
    describe '#encode_title' do
      context 'given @title set to a given test value' do
        expected_value = [ { title_non_sort_portion: nil,
                             title_sort_portion: 'Sample Title' } ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.title = 'Sample Title'
          hyacinth_adapter.encode_title
          expect(hyacinth_adapter.dynamic_field_data[:title]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_type_of_resource
    describe '#encode_type_of_resource' do
      context 'given @type_of_resource set to a given test value' do
        expected_value = [ { type_of_resource_value: 'text' } ]
        it 'constructs correct encoded format' do
          hyacinth_adapter.type_of_resource = 'text'
          hyacinth_adapter.encode_type_of_resource
          expect(hyacinth_adapter.dynamic_field_data[:type_of_resource]).to eq(expected_value)
        end
      end
    end

    ########################################## #encode_use_and_reproduction
    describe '#encode_use_and_reproduction' do
      context 'given @use_and_reproduction_uri sset to a given value' do
        let(:expected_value) do
          [
            {
              use_and_reproduction_term: { uri: "http://rightsstatements.org/vocab/InC/1.0/" }
            }
          ]
        end
        it 'constructs correct encoded format' do
          hyacinth_adapter.use_and_reproduction_uri = 'http://rightsstatements.org/vocab/InC/1.0/'
          hyacinth_adapter.encode_use_and_reproduction
          expect(hyacinth_adapter.dynamic_field_data[:use_and_reproduction]).to eq(expected_value)
        end
      end
    end

  end

  ########################################## #compose_dynamic_field_data
  describe '#compose_dynamic_field_data' do
    context 'with only mandatory title and deposited_by metadata given' do
      it 'does snot list any other field, including listing field labels with empty data' do
        @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
        @hyacinth_adapter.deposited_by = 'First Test Depositor'
        @hyacinth_adapter.title = 'Sample Title of Hyacinth Item'
        @hyacinth_adapter.compose_dynamic_field_data
        expected_data = {
          deposited_by: [{
            deposited_by_value: 'First Test Depositor'
          }],
          title: [{
            title_non_sort_portion: nil,
            title_sort_portion: 'Sample Title of Hyacinth Item'
          }]
        }
        expect(@hyacinth_adapter.dynamic_field_data).to eq(expected_data)
      end
    end

    before (:context) do
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
      @hyacinth_adapter.hyacinth_project = 'test_project'
      @hyacinth_adapter.deposited_by = 'First Test Depositor'
      @hyacinth_adapter.title = 'Sample Title of Hyacinth Item'
      @hyacinth_adapter.abstract = 'Abstract for Testing the Hyacinth Composer'
      @hyacinth_adapter.genre_value = 'articles'
      @hyacinth_adapter.genre_uri = 'http://vocab.getty.edu/aat/300048715'
      @hyacinth_adapter.language_value = 'English'
      @hyacinth_adapter.language_uri = 'http://id.loc.gov/vocabulary/iso639-2/eng'
      @hyacinth_adapter.license_uri = 'https://creativecommons.org/licenses/by/4.0/'
      @hyacinth_adapter.subjects << 'Subject one' << 'Subject two' << 'Canadian Studies'
      @hyacinth_adapter.use_and_reproduction_uri = 'http://rightsstatements.org/vocab/InC/1.0/'
      @hyacinth_adapter.notes << Sword::Metadata::Note.new('Copyright: 2016 Hyacinth Composer')
      @hyacinth_adapter.date_issued_start = '2018'
      parent_pub = Sword::Metadata::ParentPublication.new
      parent_pub.title = 'International Journal of Stuff'
      parent_pub.publish_date = '2016'
      parent_pub.volume = '10'
      parent_pub.issue = '11'
      parent_pub.start_page = '78'
      parent_pub.doi = '10.1186/s13033-015-0032-8'
      @hyacinth_adapter.parent_publication = parent_pub
      @hyacinth_adapter.type_of_resource = 'text'
      degree = Sword::Metadata::Degree.new
      degree.name = 'Ph.D.'
      degree.grantor = 'Columbia University'
      degree.discipline = ' Microbiology, Immunology and Infection'
      degree.level = 2
      @hyacinth_adapter.degree = degree
      corporate = Sword::Metadata::CorporateName.new
      corporate.role = 'originator'
      corporate.name = 'Columbia University. Microbiology, Immunology and Infection'
      @hyacinth_adapter.corporate_names << corporate
      first_author = Sword::Metadata::PersonalName.new
      first_author.last_name = 'Smith'
      first_author.first_name = 'John'
      first_author.middle_name = 'Howard'
      first_author.role = 'author'
      second_author = Sword::Metadata::PersonalName.new
      second_author.last_name = 'Doe'
      second_author.first_name = 'J'
      second_author.middle_name = 'H'
      second_author.role = 'author'
      third_author = Sword::Metadata::PersonalName.new
      third_author.full_name_naf_format = 'Kennedy, J F'
      third_author.role = 'author'
      fourth_author = Sword::Metadata::PersonalName.new
      fourth_author.full_name_naf_format = 'Kennedy, A Bee C Dee F Jay K'
      fourth_author.role = 'author'
      @hyacinth_adapter.personal_names << first_author << second_author << third_author <<
        fourth_author
      first_advisor = Sword::Metadata::PersonalName.new
      first_advisor.last_name = 'Smithy'
      first_advisor.first_name = 'Johny'
      first_advisor.middle_name = 'Howardy'
      first_advisor.role = 'thesis_advisor'
      second_advisor = Sword::Metadata::PersonalName.new
      second_advisor.last_name = 'Doey'
      second_advisor.first_name = 'J'
      second_advisor.middle_name = 'H'
      second_advisor.role = 'thesis_advisor'
      third_advisor = Sword::Metadata::PersonalName.new
      third_advisor.full_name_naf_format = 'Kennedy, J F'
      third_advisor.role = 'thesis_advisor'
      fourth_advisor = Sword::Metadata::PersonalName.new
      fourth_advisor.full_name_naf_format = 'Kennedy, A Bee C Dee F Jay K'
      fourth_advisor.role = 'thesis_advisor'
      @hyacinth_adapter.personal_names << first_advisor << second_advisor << third_advisor <<
        fourth_advisor
      @expected_dynamic_field_data =
        JSON.parse(fixture_file_upload('hyacinth_internal_format/dynamic_field_data.json').read, symbolize_names: true)
      # puts '############################################       print @expected_dynamic_field_data'
      # puts @expected_dynamic_field_data
      # puts '############################################       print JSON.generate @expected_dynamic_field_data'
      # puts JSON.generate @expected_dynamic_field_data
    end

    context 'given populated instance vars' do
      it 'creates correct dynamic_field_data for an item' do
        @hyacinth_adapter.compose_dynamic_field_data
        expect(@hyacinth_adapter.dynamic_field_data).to eq(@expected_dynamic_field_data)
      end
    end
  end

  ########################################## #compose_internal_format_item
  describe '#compose_internal_format_item' do
    before (:context) do
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
      @hyacinth_adapter.hyacinth_project = 'test_project'
      @hyacinth_adapter.title = 'Sample Title of Hyacinth Item'
      @hyacinth_adapter.compose_internal_format_item
    end

    context 'given pertinent instance vars populated with test data' do
      it 'sets the digital_object_type to item (default)' do
        expect(@hyacinth_adapter.digital_object_data[:digital_object_type][:string_key]).to eq('item')
      end

      it 'sets the project field correctly' do
        expect(@hyacinth_adapter.digital_object_data[:project][:string_key]).to eq('test_project')
      end
    end
  end

  ########################################## #compose_internal_format_asset
  describe '#compose_internal_format_asset' do
    before (:context) do
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
      @hyacinth_adapter.hyacinth_project = 'test_project'
      @hyacinth_adapter.title = 'Sample Title of Hyacinth Item'
      # @hyacinth_adapter.asset_parent_pid = 'test:12345'
      # @hyacinth_adapter.asset_import_filepath = '/foo/bar/barfoo.txt'
      asset_parent_pid = 'test:12345'
      asset_import_filepath = '/foo/bar/barfoo.txt'
      @hyacinth_adapter.compose_internal_format_asset(asset_parent_pid,
                                                      asset_import_filepath)
    end

    context 'given pertinent instance vars populated with test data' do
      it 'sets the digital_object_type to item (default)' do
        expect(@hyacinth_adapter.digital_object_data[:digital_object_type][:string_key]).to eq('asset')
      end

      it 'sets the project field correctly' do
        expect(@hyacinth_adapter.digital_object_data[:project][:string_key]).to eq('test_project')
      end

      it 'sets parent PID correctly' do
        expect(@hyacinth_adapter.digital_object_data[:parent_digital_objects].first[:identifier]).to eq('test:12345')
      end

      it 'sets the asset import filepath  correctly' do
        expect(@hyacinth_adapter.digital_object_data[:import_file][:import_path]).to eq('/foo/bar/barfoo.txt')
        expect(@hyacinth_adapter.digital_object_data[:import_file][:import_type]).to eq('upload_directory')
      end
    end
  end

  ########################################## #ingest
  describe '#ingest_item' do
    before (:context) do
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
      @hyacinth_adapter.hyacinth_project = 'test_project'
      @hyacinth_adapter.deposited_by = 'First Test Depositor'
      @hyacinth_adapter.title = 'Sample Title of Hyacinth Item'
      @hyacinth_adapter.abstract = 'Abstract for Testing the Hyacinth Composer'
      @hyacinth_adapter.genre_value = 'articles'
      @hyacinth_adapter.genre_uri = 'http://vocab.getty.edu/aat/300048715'
      @hyacinth_adapter.language_value = 'English'
      @hyacinth_adapter.language_uri = 'http://id.loc.gov/vocabulary/iso639-2/eng'
      @hyacinth_adapter.subjects << 'Subject one' << 'Subject two' << 'Canadian Studies'
      @hyacinth_adapter.notes << Sword::Metadata::Note.new('Copyright: 2016 Hyacinth Composer')
      parent_pub = Sword::Metadata::ParentPublication.new
      parent_pub.title = 'International Journal of Stuff'
      parent_pub.publish_date = '2016'
      parent_pub.volume = '10'
      parent_pub.issue = '11'
      parent_pub.start_page = '78'
      parent_pub.doi = '10.1186/s13033-015-0032-8'
      @hyacinth_adapter.parent_publication = parent_pub
      @hyacinth_adapter.type_of_resource = 'text'
      degree = Sword::Metadata::Degree.new
      degree.name = 'Ph.D.'
      degree.grantor = 'Columbia University'
      degree.discipline = ' Microbiology, Immunology and Infection'
      degree.level = 2
      @hyacinth_adapter.degree = degree
      corporate = Sword::Metadata::CorporateName.new
      corporate.role = 'originator'
      corporate.name = 'Columbia University. Microbiology, Immunology and Infection'
      @hyacinth_adapter.corporate_names << corporate
      first_author = Sword::Metadata::PersonalName.new
      first_author.last_name = 'Smith'
      first_author.first_name = 'John'
      first_author.middle_name = 'Howard'
      first_author.role = 'author'
      second_author = Sword::Metadata::PersonalName.new
      second_author.last_name = 'Doe'
      second_author.first_name = 'J'
      second_author.middle_name = 'H'
      second_author.role = 'author'
      third_author = Sword::Metadata::PersonalName.new
      third_author.full_name_naf_format = 'Kennedy, J F'
      third_author.role = 'author'
      fourth_author = Sword::Metadata::PersonalName.new
      fourth_author.full_name_naf_format = 'Kennedy, A Bee C Dee F Jay K'
      fourth_author.role = 'author'
      @hyacinth_adapter.personal_names << first_author << second_author << third_author <<
        fourth_author
      first_advisor = Sword::Metadata::PersonalName.new
      first_advisor.last_name = 'Smithy'
      first_advisor.first_name = 'Johny'
      first_advisor.middle_name = 'Howardy'
      first_advisor.role = 'thesis_advisor'
      second_advisor = Sword::Metadata::PersonalName.new
      second_advisor.last_name = 'Doey'
      second_advisor.first_name = 'J'
      second_advisor.middle_name = 'H'
      second_advisor.role = 'thesis_advisor'
      third_advisor = Sword::Metadata::PersonalName.new
      third_advisor.full_name_naf_format = 'Kennedy, J F'
      third_advisor.role = 'thesis_advisor'
      fourth_advisor = Sword::Metadata::PersonalName.new
      fourth_advisor.full_name_naf_format = 'Kennedy, A Bee C Dee F Jay K'
      fourth_advisor.role = 'thesis_advisor'
      @hyacinth_adapter.personal_names << first_advisor << second_advisor << third_advisor <<
        fourth_advisor
      @expected_dynamic_field_data =
        JSON.parse(fixture_file_upload('hyacinth_internal_format/dynamic_field_data.json').read, symbolize_names: true)
      @hyacinth_adapter.compose_internal_format_item
      # since this is a spec, do not send POST request to server
      @hyacinth_adapter.no_op_post = true
      @hyacinth_adapter.ingest_item
    end

    context 'given pertinent instance vars populated with test data' do
      it 'sets the digital_object_type to item (default)' do
        expect(@hyacinth_adapter.digital_object_data[:digital_object_type][:string_key]).to eq('item')
      end
    end
  end

  describe 'expected_and_retrieved_asset_pids_match?' do
    before(:example) do
      http_success = double("http_success")
      allow(http_success).to receive(:is_a?) { true }
      allow(http_success).to receive(:body) { JSON.generate({'ordered_child_digital_objects' => [ { 'pid' => 'ac:12344321'} ] } ) }
      allow_any_instance_of(Net::HTTP).to receive(:start).and_return(http_success)
    end
    it "returns true if pids match" do
      subject.instance_variable_set(:@asset_pids, ['ac:12344321'])
      res = subject.expected_and_retrieved_asset_pids_match?
      expect(res).to be(true)
    end

    it "returns false if pids don't match" do
      subject.instance_variable_set(:@asset_pids, ['ac:123456789'])
      res = subject.expected_and_retrieved_asset_pids_match?
      expect(res).to be(false)
    end
  end
end
