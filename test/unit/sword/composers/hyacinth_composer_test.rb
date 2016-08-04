require 'test_helper'
require 'sword/composers/hyacinth_composer'
require 'sword/deposit_content'

class HyacinthComposerTest < ActiveSupport::TestCase
  setup do
    @deposit_content = Sword::DepositContent.new
    @deposit_content.title = 'Testing the Hyacinth Composer'
    @composer = Sword::Composers::HyacinthComposer.new
  end

  test "assert true" do
    assert true
  end
end
