require 'test_helper'
require 'sword/composers/hyacinth_composer'

class HyacinthComposerTest < ActiveSupport::TestCase
  setup do
    @composer = Sword::Composers::HyacinthComposer.new
  end

  test "assert true" do
    assert true
  end
end
