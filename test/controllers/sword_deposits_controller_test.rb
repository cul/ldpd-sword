require 'test_helper'

class SwordDepositsControllerTest < ActionController::TestCase
  setup do
    @sword_deposit = sword_deposits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sword_deposits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sword_deposit" do
    assert_difference('SwordDeposit.count') do
      post :create, sword_deposit: {  }
    end

    assert_redirected_to sword_deposit_path(assigns(:sword_deposit))
  end

  test "should show sword_deposit" do
    get :show, id: @sword_deposit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sword_deposit
    assert_response :success
  end

  test "should update sword_deposit" do
    patch :update, id: @sword_deposit, sword_deposit: {  }
    assert_redirected_to sword_deposit_path(assigns(:sword_deposit))
  end

  test "should destroy sword_deposit" do
    assert_difference('SwordDeposit.count', -1) do
      delete :destroy, id: @sword_deposit
    end

    assert_redirected_to sword_deposits_path
  end
end
