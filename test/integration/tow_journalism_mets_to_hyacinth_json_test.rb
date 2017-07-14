require 'test_helper'

class TowJournalismMetsToHyacinthJsonTest < ActionDispatch::IntegrationTest

  setup do

    content_dir = File.dirname(fixture_path_for('tow_journalism/mets.xml'))
    parser = Sword::Parsers::TowJournalismParser.new
    deposit_content = parser.parse(content_dir, nil)
    assert deposit_content.is_a? Sword::DepositContent
    hyacinth_composer =
      Sword::Composers::HyacinthComposer.new(deposit_content,
                                             'test-project',
                                             'Tow Center for Digital Journalism')

    # temporarliy bypass private method restriction in order to test private method
    Sword::Composers::HyacinthComposer.send(:public, :compose_dynamic_field_data)
    hyacinth_composer.compose_dynamic_field_data
    @actual_result = hyacinth_composer.dynamic_field_data
    @expected_result = 
      JSON.parse(fixture_file('hyacinth_data/tow_journalism_test_case_1.json'),
                 symbolize_names: true)

  end

  test "verify title value" do
    assert_equal @actual_result[:title], @expected_result[:title]
  end

  test "verify name values" do
    assert_equal @actual_result[:name], @expected_result[:name]
  end

  test "verify abstract value" do
    assert_equal @actual_result[:abstract], @expected_result[:abstract]
  end

  test "verify genre value" do
    assert_equal @actual_result[:genre], @expected_result[:genre]
  end

  test "verify language value" do
    assert_equal @actual_result[:language], @expected_result[:language]
  end

  test "verify date value" do
    assert_equal @actual_result[:date_issued], @expected_result[:date_issued]
  end

  test "verify deposited_by value" do
    assert_equal @actual_result[:deposited_by], @expected_result[:deposited_by]
  end

  test "verify JSON generated from mets is correct" do
    assert_equal @actual_result, @expected_result
  end

end
