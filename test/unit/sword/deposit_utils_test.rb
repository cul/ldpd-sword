require 'test_helper'
require 'sword/deposit_utils'

class DepositUtilsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    @test_zip_file = fixture_file_upload('/zip_files/test.zip')
    @test_dir = "tmp/#{Process.pid.to_s}"
    @path_unzipped_file_pdf = File.join(@test_dir, 'test.pdf')
    @path_unzipped_file_txt = File.join(@test_dir, 'test.txt')
    @path_saved_file = File.join(@test_dir, 'test_saved_file.txt')
  end

  teardown do
    FileUtils.rm(@path_unzipped_file_pdf) if File.exist?(@path_unzipped_file_pdf)
    FileUtils.rm(@path_unzipped_file_txt) if File.exist?(@path_unzipped_file_txt)
    FileUtils.rm(@path_saved_file) if File.exist?(@path_saved_file)
    FileUtils.rmdir(@test_dir)
  end

  test "files correctly unziped" do
    assert_not File.exist? @path_unzipped_file_pdf
    assert_not File.exist? @path_unzipped_file_txt
    Sword::DepositUtils.unpackZip(@test_zip_file, @test_dir)
    assert File.exist? @path_unzipped_file_pdf
    assert File.exist? @path_unzipped_file_txt
  end

  test "should process package file" do
    # assert_not File.exist? @path_saved_file
    Sword::DepositUtils.process_package_file(@test_zip_file.read,'test.zip')
    # assert File.exist? @path_saved_file
    assert true
  end
end
