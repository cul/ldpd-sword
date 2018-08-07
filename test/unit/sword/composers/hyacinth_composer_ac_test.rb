require 'test_helper'
require 'sword/composers/hyacinth_composer'
require 'sword/deposit_content'
require 'sword/person'

class HyacinthComposerAcTest < ActiveSupport::TestCase
  setup do
    @deposit_content = Sword::DepositContent.new
    @deposit_content.title = 'Test Deposit'
    @deposit_content.abstract = 'Abstract for Testing the Hyacinth Composer'
    # @deposit_content.corporate_names = ['Columbia University. Microbiology, Immunology and Infection']
    # @deposit_content.corporate_role = 'originator'
    # @deposit_content.include_degree_info = true
    
    first_author = Sword::Person.new
    first_author.full_name_naf_format = 'Smith, John'
    first_author.role = 'should not see this'
    first_author.affiliation = 'should not see this'
    second_author = Sword::Person.new
    second_author.full_name_naf_format = 'User, Test'
    second_author.uni = 'tu123'
    second_author.role = 'should not see this'
    second_author.affiliation = 'should not see this'
    third_author = Sword::Person.new
    third_author.full_name_naf_format = 'Za, Carla'
    third_author.role = 'should not see this'
    third_author.affiliation = 'should not see this'
    @deposit_content.authors = []
    @deposit_content.authors << first_author << second_author << third_author

    @deposit_content.abstract = 'Abstract blah blah bla'
    # @deposit_content.genre_value = 'articles'
    # @deposit_content.genre_uri = 'http://vocab.getty.edu/aat/300048715'
    # @deposit_content.language_value = 'English'
    # @deposit_content.language_uri = 'http://id.loc.gov/vocabulary/iso639-2/eng'
    # @deposit_content.subjects = []
    # @deposit_content.subjects << 'Subject one' << 'Subject two' << 'Canadian Studies'
    @deposit_content.note_internal = 'This is the best deposit ever, just FYI'
    # @deposit_content.parent_publication_title = 'International Journal of Stuff'
    # @deposit_content.pubdate = '2016'
    # @deposit_content.volume = '10'
    # @deposit_content.issue = '11'
    # @deposit_content.fpage = '78'
    # @deposit_content.pub_doi = '10.1186/s13033-015-0032-8'
    # @deposit_content.type_of_resource = 'text'
    # @deposit_content.degree_name = 'Ph.D.'
  
    @hyacinth_composer = Sword::Composers::HyacinthComposer.new(@deposit_content,
                                                                'test-project',
                                                                'Academic Commons')
    # temporarily bypass private method restriction in order to test private method
    Sword::Composers::HyacinthComposer.send(:public, :compose_dynamic_field_data)
    @hyacinth_composer.compose_dynamic_field_data  
    @actual_result = @hyacinth_composer.dynamic_field_data
    @expected_result = JSON.parse(fixture_file('hyacinth_data/dynamic_field_data_test_ac.json'), symbolize_names: true)
  end

  test "#compose_dynamic_field_data via #set_title encodes title correctly" do
    assert_equal @actual_result[:title], @expected_result[:title]
  end

  test "#compose_dynamic_field_data via #set_names encodes names correctly (authors), contains single letter strings" do
    assert_equal @actual_result[:name][4], @expected_result[:name][4]
  end

  test "#compose_dynamic_field_data via #set_names encodes names correctly (advisors), contains single letter strings" do
    assert_equal @actual_result[:name][8], @expected_result[:name][8]
  end

  test "#compose_dynamic_field_data via #set_names encodes names correctly" do
    assert_equal @actual_result[:name], @expected_result[:name]
  end

  test "#compose_dynamic_field_data via #set_abstract encodes abstract correctly" do
    assert_equal @actual_result[:abstract], @expected_result[:abstract]
  end

  test "#compose_dynamic_field_data via #set_genre encodes genre correctly" do
    assert_equal @actual_result[:genre], @expected_result[:genre]
  end

  test "#compose_dynamic_field_data via #set_language encodes language correctly" do
    assert_equal @actual_result[:language], @expected_result[:language]
  end

  test "#compose_dynamic_field_data via #set_subjects encodes subject topics correctly" do
    assert_equal @actual_result[:subject_topic], @expected_result[:subject_topic]
  end

  test "#compose_dynamic_field_data via #set_note encodes abstract correctly" do
    assert_equal @actual_result[:note], @expected_result[:note]
  end

  test "#compose_dynamic_field_data via #set_deposited_by encodes deposited_by correctly" do
    assert_equal @actual_result[:deposited_by], @expected_result[:deposited_by]
  end

  test "#compose_dynamic_field_data via #set_parent_publication encodes parent publication correctly" do
    assert_equal @actual_result[:parent_publication], @expected_result[:parent_publication]
  end

  test "#compose_dynamic_field_data via #set_type_of_resource encodes type_of_resource correctly" do
    assert_equal @actual_result[:type_of_resource], @expected_result[:type_of_resource]
  end

  test "should #compose_dynamic_field_data encodes correctly" do
    assert_equal @actual_result, @expected_result
  end
end
