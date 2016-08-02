require 'test_helper'
require 'sword/deposit_utils'

class DepositUtilsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    @test_file = fixture_file_upload('/zip_files/test.zip')
    @unzip_dir = 'tmp/'
    @path_expected_file_pdf = File.join(@unzip_dir, 'test.pdf')
    @path_expected_file_txt = File.join(@unzip_dir, 'test.txt')
  end

  teardown do
    FileUtils.rm(@path_expected_file_pdf) if File.exist?(@path_expected_file_pdf)
    FileUtils.rm(@path_expected_file_txt) if File.exist?(@path_expected_file_txt)
  end

  test "files correctly unziped" do
    assert_not File.exist? @path_expected_file_pdf
    assert_not File.exist? @path_expected_file_txt
    Sword::DepositUtils.unpackZip(@test_file, @unzip_dir)
    assert File.exist? @path_expected_file_pdf
    assert File.exist? @path_expected_file_txt
  end
end
