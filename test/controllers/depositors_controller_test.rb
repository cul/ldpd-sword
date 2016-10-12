require 'test_helper'

class DepositorsControllerTest < ActionController::TestCase
  setup do
    @depositor = depositors(:first_depositor)
  end

  teardown do
    sign_out @user unless @user.nil?
  end

  test "should get index" do
    @user = users(:test_user)
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:depositors)
  end

  test "should get new" do
    @user = users(:admin_user)
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create depositor" do
    @user = users(:admin_user)
    sign_in @user
    assert_difference('Depositor.count') do
      post :create, depositor: { name: "Test Depositor",
                                 basic_authentication_user_id: "testdid",
                                 password: "testdidpasswd",
                                 password_confirmation: "testdidpasswd" }
    end

    assert_redirected_to depositor_path(assigns(:depositor))
  end

  test "should show depositor" do
    @user = users(:test_user)
    sign_in @user
    get :show, id: @depositor
    assert_response :success
  end

  test "should get edit" do
    @user = users(:admin_user)
    sign_in @user
    get :edit, id: @depositor
    assert_response :success
  end

  test "should update depositor" do
    @user = users(:admin_user)
    sign_in @user
    patch :update, id: @depositor, depositor: {  }
    assert_redirected_to depositor_path(assigns(:depositor))
  end

  test "should destroy depositor" do
    @user = users(:admin_user)
    sign_in @user
    assert_difference('Depositor.count', -1) do
      delete :destroy, id: @depositor
    end

    assert_redirected_to depositors_path
  end
end
