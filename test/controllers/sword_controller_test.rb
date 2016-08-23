require 'test_helper'

class SwordControllerTest < ActionController::TestCase

  setup do
    # see depositor_collection_pairings.yml for pairings
    # between depositor and collection (i.e. which collections
    # are accessible to a depositor
    @first_depositor =  depositors(:first_depositor)
    @first_collection = collections(:first_collection)
    @second_depositor = depositors(:first_depositor)
    @second_collection = collections(:second_collection)
    @request.headers["X-On-Behalf-Of"] = "FFFFFFFFFFFFFFFFFFFFFFFFOOOOOOOOOOOOOOOOOOOOOOOOOOBBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAARRRRRRRRRRRRRRRRRR"
    @request.body.write( "Hi, Fred")
    @test_file = fixture_file_upload('/zip_files/test_one.zip')
  end

  def setup_auth(depositor_fixture_name, depositor_passwd, bad_passwd = false)
    @user_id = depositors(depositor_fixture_name).basic_authentication_user_id
    # copied the clear text password from the fixtures file depositors.yml
    if bad_passwd
      b64 = Base64.encode64("#{@user_id}:#{depositor_passwd}foo")
    else
      b64 = Base64.encode64("#{@user_id}:#{depositor_passwd}")
    end
    @request.env['HTTP_AUTHORIZATION'] = "Basic #{b64}".strip
  end

  test "first depositor should post deposit succesfully into first collection" do
    setup_auth :first_depositor, 'firstdpasswd'
    @request.env['RAW_POST_DATA'] = @test_file.read
    @request.env['CONTENT_TYPE'] = "application/zip"
    post :deposit, collection_slug: @first_collection.slug
    # puts @controller.inspect
    assert_response :success
  end

  test "second depositor should post deposit succesfully into second collection" do
    setup_auth :second_depositor, 'seconddpasswd'
    @request.env['RAW_POST_DATA'] = @test_file.read
    post :deposit, collection_slug: @second_collection.slug
    assert_response :success
  end

  test "should post deposit, failure, unknown collection slug" do
    setup_auth :first_depositor, 'firstdpasswd'
    post :deposit, collection_slug: 'collection-on'
    # assert_response 400
    assert_response :bad_request
  end

  test "should post deposit, authentication failure" do
    setup_auth :first_depositor, 'firstdpasswd', true
    post :deposit, collection_slug: @first_collection.slug
    assert_response 511
  end

  test "should post deposit, failure, no access to specified collection" do
    # fixture :second_depositor does not have access to fixture :first_collection
    # see depositor_collection_pairings.yml
    setup_auth :second_depositor, 'seconddpasswd'
    post :deposit, collection_slug: @first_collection.slug
    assert_response :bad_request
  end
end
