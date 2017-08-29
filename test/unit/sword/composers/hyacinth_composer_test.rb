require 'test_helper'
require 'sword/composers/hyacinth_composer'
require 'sword/deposit_content'
require 'sword/person'

class HyacinthComposerTest < ActiveSupport::TestCase
  setup do
    @deposit_content = Sword::DepositContent.new
    @deposit_content.title = 'Title for Testing the Hyacinth Composer'
    @deposit_content.abstract = 'Abstract for Testing the Hyacinth Composer'
    @deposit_content.corporate_names = ['Columbia University. Microbiology, Immunology and Infection']
    @deposit_content.corporate_role = 'originator'
    @deposit_content.include_degree_info = true
    
    first_author = Sword::Person.new
    first_author.last_name = 'Smith'
    first_author.first_name = 'John'
    first_author.middle_name = 'Howard'
    first_author.role = 'should not see this'
    first_author.affiliation = 'should not see this'
    second_author = Sword::Person.new
    second_author.last_name = 'Doe'
    second_author.first_name = 'J'
    second_author.middle_name = 'H'
    second_author.role = 'should not see this'
    second_author.affiliation = 'should not see this'
    third_author = Sword::Person.new
    third_author.full_name_naf_format = 'Kennedy, J F'
    third_author.role = 'should not see this'
    third_author.affiliation = 'should not see this'
    fourth_author = Sword::Person.new
    fourth_author.full_name_naf_format = 'Kennedy, A Bee C Dee F Jay K'
    fourth_author.role = 'should not see this'
    fourth_author.affiliation = 'should not see this'
    @deposit_content.authors = []
    @deposit_content.authors << first_author << second_author << third_author <<
      fourth_author

    first_advisor = Sword::Person.new
    first_advisor.last_name = 'Smithy'
    first_advisor.first_name = 'Johny'
    first_advisor.middle_name = 'Howardy'
    first_advisor.role = 'should not see this'
    first_advisor.affiliation = 'should not see this'
    second_advisor = Sword::Person.new
    second_advisor.last_name = 'Doey'
    second_advisor.first_name = 'J'
    second_advisor.middle_name = 'H'
    second_advisor.role = 'should not see this'
    second_advisor.affiliation = 'should not see this'
    third_advisor = Sword::Person.new
    third_advisor.full_name_naf_format = 'Kennedy, J F'
    third_advisor.role = 'should not see this'
    third_advisor.affiliation = 'should not see this'
    fourth_advisor = Sword::Person.new
    fourth_advisor.full_name_naf_format = 'Kennedy, A Bee C Dee F Jay K'
    fourth_advisor.role = 'should not see this'
    fourth_advisor.affiliation = 'should not see this'
    @deposit_content.advisors = []
    @deposit_content.advisors << first_advisor << second_advisor << third_advisor <<
      fourth_advisor

    @deposit_content.abstract = 'Abstract for Testing the Hyacinth Composer'
    @deposit_content.genre_value = 'articles'
    @deposit_content.genre_uri = 'http://vocab.getty.edu/aat/300048715'
    @deposit_content.language_value = 'English'
    @deposit_content.language_uri = 'http://id.loc.gov/vocabulary/iso639-2/eng'
    @deposit_content.subjects = []
    @deposit_content.subjects << 'Subject one' << 'Subject two' << 'Canadian Studies'
    @deposit_content.note = 'Copyright: 2016 Hyacinth Composer'
    @deposit_content.parent_publication_title = 'International Journal of Stuff'
    @deposit_content.pubdate = '2016'
    @deposit_content.volume = '10'
    @deposit_content.issue = '11'
    @deposit_content.fpage = '78'
    @deposit_content.pub_doi = '10.1186/s13033-015-0032-8'
  
    @hyacinth_composer = Sword::Composers::HyacinthComposer.new(@deposit_content,
                                                                'test-project',
                                                                'First Test Depositor')
    # temporarily bypass private method restriction in order to test private method
    Sword::Composers::HyacinthComposer.send(:public, :compose_dynamic_field_data)
    @hyacinth_composer.compose_dynamic_field_data  
    @actual_result = @hyacinth_composer.dynamic_field_data
    @expected_result = JSON.parse(fixture_file('hyacinth_data/dynamic_field_data_test_case_1.json'), symbolize_names: true)
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

  test "should #compose_dynamic_field_data encodes correctly" do
    assert_equal @actual_result, @expected_result
  end
end
