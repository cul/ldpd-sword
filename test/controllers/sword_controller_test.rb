require 'test_helper'

class SwordControllerTest < ActionController::TestCase

  setup do
    @depositor =  depositors(:first_depositor)
    @collection = collections(:first_collection)
    @depositor.collections << @collection
  end

  def setup_auth(bad_passwd = false)
    # config = YAML.load_file(fixture_path_for('sword/config.yml'))
    # Deposits::Sword::SwordTools.instance_variable_set(:@all_config,config)
    @user_id = depositors(:first_depositor).basic_authentication_user_id
    @password = depositors(:first_depositor).basic_authentication_password
    # @password = rand(10000).to_s(16)
    # testuser = Deposits::Sword::SwordTools.getUserConfig.detect do |m|
    # m['name'] == @user
    # end
    # testuser['password'] = @password
    # b64 = Base64.encode64("#{@user_id}:#{@password}")
    if bad_passwd
      b64 = Base64.encode64("#{@user_id}:#{@password}foo")
    else
      b64 = Base64.encode64("#{@user_id}:#{@password}")
    end
    @auth_header = "Basic #{b64}".strip
  end

  test "should post deposit, failure, unknown collection slug" do
    setup_auth
    @request.env['HTTP_AUTHORIZATION'] = @auth_header
    post :deposit, collection_slug: 'collection-on'
    assert_response 400
  end

  test "should post deposit, authentication failure" do
    setup_auth true
    @request.env['HTTP_AUTHORIZATION'] = @auth_header
    post :deposit, collection_slug: 'first-collection'
    assert_response 511
  end

  test "should post deposit, failure, no access to specified collection" do
    setup_auth
    @request.env['HTTP_AUTHORIZATION'] = @auth_header
    post :deposit, collection_slug: 'second-collection'
    assert_response 400
  end

  test "should post deposit" do
    setup_auth
    @request.env['HTTP_AUTHORIZATION'] = @auth_header
    post :deposit, collection_slug: 'first-collection'
    assert_response :success
  end
end
