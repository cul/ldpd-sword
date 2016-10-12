require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  setup do
    @collection = collections(:first_collection)
  end

  teardown do
    sign_out @user
  end

  test "should get index" do
    @user = users(:test_user)
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:collections)
  end

  test "should get new" do
    @user = users(:admin_user)
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create collection" do
    @user = users(:admin_user)
    sign_in @user
    assert_difference('Collection.count') do
      post :create, collection: { name: "Test Collection",
                                  slug: "test-collection",
                                  atom_title: "Atom Title of the Test Collection" }
    end

    assert_redirected_to collection_path(assigns(:collection))
  end

  test "should show collection" do
    @user = users(:test_user)
    sign_in @user
    get :show, id: @collection
    assert_response :success
  end

  test "should get edit" do
    @user = users(:admin_user)
    sign_in @user
    get :edit, id: @collection
    assert_response :success
  end

  test "should update collection" do
    @user = users(:admin_user)
    sign_in @user
    patch :update, id: @collection, collection: { name: "New Name Test Collection"  }
    assert_redirected_to collection_path(assigns(:collection))
  end

  test "should destroy collection" do
    @user = users(:admin_user)
    sign_in @user
    assert_difference('Collection.count', -1) do
      delete :destroy, id: @collection
    end

    assert_redirected_to collections_path
  end
end
