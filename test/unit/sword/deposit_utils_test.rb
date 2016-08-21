require 'test_helper'
require 'sword/deposit_utils'

class DepositUtilsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    @test_zip_file = fixture_file_upload('/zip_files/test.zip')
    @test_zip_file_path = Rails.root.join('test/fixtures/zip_files/test.zip')
    @test_dir = File.join(SWORD_CONFIG[:unzip_dir],"tmp_#{Time.now.to_i}")
    @path_unzipped_file_pdf = File.join(@test_dir, 'test.pdf')
    @path_unzipped_file_txt = File.join(@test_dir, 'test.txt')
  end

  teardown do
    FileUtils.rm(@path_unzipped_file_pdf) if File.exist?(@path_unzipped_file_pdf)
    FileUtils.rm(@path_unzipped_file_txt) if File.exist?(@path_unzipped_file_txt)
    FileUtils.rmdir(@test_dir)
  end

  test "files correctly unziped" do
    assert_not File.exist? @path_unzipped_file_pdf
    assert_not File.exist? @path_unzipped_file_txt
    Sword::DepositUtils.unpackZip(@test_zip_file_path, @test_dir)
    assert File.exist? @path_unzipped_file_pdf
    assert File.exist? @path_unzipped_file_txt
  end

  test "should process package file" do
    # assert_not File.exist? @path_saved_file
    save_path = Sword::DepositUtils.process_package_file(@test_zip_file.read,'test.zip')
    # assert File.exist? @path_saved_file
    assert File.exist? File.join(save_path,'test.zip')
    assert File.exist? File.join(save_path,SWORD_CONFIG[:contents_zipfile_subdir],'test.pdf')
    assert File.exist? File.join(save_path,SWORD_CONFIG[:contents_zipfile_subdir],'test.txt')
    # cleanup
    FileUtils.rm File.join(save_path,'test.zip')
    FileUtils.rm File.join(save_path,SWORD_CONFIG[:contents_zipfile_subdir],'test.pdf')
    FileUtils.rm File.join(save_path,SWORD_CONFIG[:contents_zipfile_subdir],'test.txt')
    FileUtils.rmdir File.join(save_path,SWORD_CONFIG[:contents_zipfile_subdir])
    FileUtils.rmdir save_path
  end
end
