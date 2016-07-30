require 'test_helper'

class SwordControllerTest < ActionController::TestCase
  test "should get deposit" do
    get :deposit
    assert_response :success
  end

end
