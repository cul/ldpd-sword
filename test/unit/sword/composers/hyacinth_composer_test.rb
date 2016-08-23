require 'test_helper'
require 'sword/composers/hyacinth_composer'
require 'sword/deposit_content'

class HyacinthComposerTest < ActiveSupport::TestCase
  setup do
    @deposit_content = Sword::DepositContent.new
    @deposit_content.title = 'Title for Testing the Hyacinth Composer'
    @deposit_content.abstract = 'Abstract for Testing the Hyacinth Composer'
    @hyacinth_composer = Sword::Composers::HyacinthComposer.new(@deposit_content,
                                                                'test-project')
    # temporarily bypass private method restriction in order to test private method
    Sword::Composers::HyacinthComposer.send(:public, :compose_dynamic_field_data)
    @hyacinth_composer.compose_dynamic_field_data  
    @actual_result = @hyacinth_composer.dynamic_field_data
    @expected_result = JSON.parse(fixture_file('hyacinth_data/dynamic_field_data_test_case_1.json'), symbolize_names: true)
  end

  test "#compose_dynamic_field_data via #set_title encodes title correctly" do
    assert_equal @actual_result[:title], @expected_result[:title]
  end

  test "#compose_dynamic_field_data via #set_abstract encodes abstract correctly" do
    assert_equal @actual_result[:abstract], @expected_result[:abstract]
  end

  test "should #compose_dynamic_field_data encodes correctly" do
    assert_equal @actual_result, @expected_result
  end
end
