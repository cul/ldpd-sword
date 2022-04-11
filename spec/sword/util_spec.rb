require 'rails_helper'

require 'sword/util.rb'

RSpec.describe Sword::Util do
  context "API/interface" do
    it 'has ::unzip class method that takes filename to unzip and location to store contents' do
      expect(subject.class).to respond_to(:unzip).with(2).arguments
    end
  end

  describe '::unzip' do
    context 'Given zip file conntaining two files, ::unzip' do
      zip_file =  Rails.root.join 'spec/fixtures/zip_files/test_unzip.zip'
      destination =  Rails.root.join "tmp/testunzip_#{Time.now.to_i}"
      expected_filenames = ['unzip_test_file1.txt',
                            'unzip_test_filetwo.txt']

      before(:context) do
        Dir.mkdir(destination)
      end

      it 'unzips the files and stores them in the given location' do
        expect(File.exist?(File.join(destination, expected_filenames.first))
              ).to eq(false), 'Precondition of test not met: File already exists'

        expect(File.exist?(File.join(destination, expected_filenames.second))
              ).to eq(false), 'Precondition of test not met: File already exists'

        subject.class.unzip(zip_file, destination)

        expect(File.exist?(File.join(destination, expected_filenames.first))).to eq(true)
        expect(File.exist?(File.join(destination, expected_filenames.second))).to eq(true)
      end

      after(:context) do
        FileUtils.rm_rf(destination)
      end
    end

    context 'Given zip file conntaining three files with one in a subdir, ::unzip' do
      zip_file =  Rails.root.join 'spec/fixtures/zip_files/test_unzip_with_subdir.zip'
      destination =  Rails.root.join "tmp/testunzipwithsubdir_#{Time.now.to_i}"
      expected_filenames = ['unzip_test_file1.txt',
                            'unzip_test_filetwo.txt',
                            'test_subdir/unzip_test_file3.txt']

      before(:context) do
        Dir.mkdir(destination)
      end

      it 'unzips the files and stores them in the given location' do
        expect(File.exist?(File.join(destination, expected_filenames.first))
              ).to eq(false), 'Precondition of test not met: File already exists'
        expect(File.exist?(File.join(destination, expected_filenames.second))
              ).to eq(false), 'Precondition of test not met: File already exists'
        expect(File.exist?(File.join(destination, expected_filenames.third))
              ).to eq(false), 'Precondition of test not met: File already exists'
        subject.class.unzip(zip_file, destination)
        expect(File.exist?(File.join(destination, expected_filenames.first))).to eq(true)
        expect(File.exist?(File.join(destination, expected_filenames.second))).to eq(true)
        expect(File.exist?(File.join(destination, expected_filenames.third))).to eq(true)
      end

      after(:context) do
        FileUtils.rm_rf(destination)
      end
    end
  end
end
