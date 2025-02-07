require 'rails_helper'

require 'sword/adapters/hyacinth_adapter.rb'

RSpec.describe Sword::Adapters::HyacinthAdapter do
  ########################################## Initial state
  describe 'Initial state' do
    encoder_class = Sword::Encoders::JsonHyacinth2

    context '#initialize' do
      it 'sets @dynamic_field_data to a new empty Hash' do
        expect(described_class.new(encoder_class).dynamic_field_data).to be_an_instance_of(Hash)
        expect(described_class.new(encoder_class).dynamic_field_data).to be_empty
      end

      it 'sets @corporate_names to a new empty Array' do
        expect(described_class.new(encoder_class).corporate_names).to be_an_instance_of(Array)
        expect(described_class.new(encoder_class).corporate_names).to be_empty
      end

      it 'sets @personal_names to a new empty Array' do
        expect(described_class.new(encoder_class).personal_names).to be_an_instance_of(Array)
        expect(described_class.new(encoder_class).personal_names).to be_empty
      end

      it 'sets @subject to a new empty Array' do
        expect(described_class.new(encoder_class).subjects).to be_an_instance_of(Array)
        expect(described_class.new(encoder_class).subjects).to be_empty
      end
    end
  end

  ########################################## #compose_internal_format_item
  describe '#compose_internal_format_item' do
    before (:context) do
      encoder_class = Sword::Encoders::JsonHyacinth2
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new encoder_class
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
      encoder_class = Sword::Encoders::JsonHyacinth2
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new encoder_class
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
      encoder_class = Sword::Encoders::JsonHyacinth2
      @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new encoder_class
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
      @adapter = Sword::Adapters::HyacinthAdapter.new(Sword::Encoders::JsonHyacinth2)
      http_success = double("http_success")
      allow(http_success).to receive(:is_a?) { true }
      allow(http_success).to receive(:body) { JSON.generate({'ordered_child_digital_objects' => [ { 'pid' => 'ac:12344321'} ] } ) }
      allow_any_instance_of(Net::HTTP).to receive(:start).and_return(http_success)
    end
    it "returns true if pids match" do
      @adapter.instance_variable_set(:@asset_pids, ['ac:12344321'])
      res = @adapter.expected_and_retrieved_asset_pids_match?
      expect(res).to be(true)
    end

    it "returns false if pids don't match" do
      @adapter.instance_variable_set(:@asset_pids, ['ac:123456789'])
      res = @adapter.expected_and_retrieved_asset_pids_match?
      expect(res).to be(false)
    end
  end
end
