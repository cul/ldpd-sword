require 'test_helper'

class SwordControllerTest < ActionController::TestCase

  def setup_auth
    # config = YAML.load_file(fixture_path_for('sword/config.yml'))
    # Deposits::Sword::SwordTools.instance_variable_set(:@all_config,config)
    @user_id = depositors(:one).basic_authentication_user_id
    @password = depositors(:one).basic_authentication_password
    # @password = rand(10000).to_s(16)
    # testuser = Deposits::Sword::SwordTools.getUserConfig.detect do |m|
    # m['name'] == @user
    # end
    # testuser['password'] = @password
    b64 = Base64.encode64("#{@user_id}:#{@password}")
    @auth_header = "Basic #{b64}".strip
  end

  test "should post deposit" do
    setup_auth
    @request.env['HTTP_AUTHORIZATION'] = @auth_header
    post :deposit, collection_slug: 'collection-one'
    assert_response :success
  end

end
