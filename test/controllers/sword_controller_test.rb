require 'test_helper'

class SwordControllerTest < ActionController::TestCase
  test "should get deposit" do
    get :deposit, collection_slug: 'fff'
    assert_response :success
  end
  test "should post deposit" do
    post :deposit, collection_slug: 'fff'
    assert_response :success
  end

end
