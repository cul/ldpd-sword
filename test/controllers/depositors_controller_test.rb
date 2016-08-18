require 'test_helper'

class DepositorsControllerTest < ActionController::TestCase
  setup do
    @depositor = depositors(:first_depositor)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:depositors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create depositor" do
    assert_difference('Depositor.count') do
      post :create, depositor: { name: "Test Depositor",
                                 basic_authentication_user_id: "testdid",
                                 password: "testdidpasswd",
                                 password_confirmation: "testdidpasswd" }
    end

    assert_redirected_to depositor_path(assigns(:depositor))
  end

  test "should show depositor" do
    get :show, id: @depositor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @depositor
    assert_response :success
  end

  test "should update depositor" do
    patch :update, id: @depositor, depositor: {  }
    assert_redirected_to depositor_path(assigns(:depositor))
  end

  test "should destroy depositor" do
    assert_difference('Depositor.count', -1) do
      delete :destroy, id: @depositor
    end

    assert_redirected_to depositors_path
  end
end
