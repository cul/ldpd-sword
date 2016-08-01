require 'test_helper'
require 'sword/deposit_utils'

class DepositUtilsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess
  setup do
    test_file = fixture_file_upload('/zip_files/test.zip')
    Sword::DepositUtils.unpackZip(test_file, 'tmp/')
  end

  test "assert true" do
    assert true
  end
end
