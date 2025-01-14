require 'rails_helper'

require 'sword/util.rb'

RSpec.describe Sword::Util do
  describe '::unzip' do
    before(:example) do
      @destination =  Rails.root.join "tmp/testunzip_#{Time.now.to_i}"
      Dir.mkdir(@destination)
    end

    after(:example) do
      FileUtils.rm_rf(@destination)
    end

    context 'Given zip file conntaining two files, ::unzip' do
      zip_file =  Rails.root.join 'spec/fixtures/zip_files/test_unzip.zip'
      expected_filenames = ['unzip_test_file1.txt',
                            'unzip_test_filetwo.txt']

      it 'unzips the files and stores them in the given location' do
        expect(File.exist?(File.join(@destination, expected_filenames.first))
              ).to eq(false), 'Precondition of test not met: File already exists'

        expect(File.exist?(File.join(@destination, expected_filenames.second))
              ).to eq(false), 'Precondition of test not met: File already exists'

        subject.class.unzip(zip_file, @destination)

        expect(File.exist?(File.join(@destination, expected_filenames.first))).to eq(true)
        expect(File.exist?(File.join(@destination, expected_filenames.second))).to eq(true)
      end

    end

    context 'Given zip file conntaining three files with one in a subdir, ::unzip' do
      zip_file =  Rails.root.join 'spec/fixtures/zip_files/test_unzip_with_subdir.zip'
      expected_filenames = ['unzip_test_file1.txt',
                            'unzip_test_filetwo.txt',
                            'test_subdir/unzip_test_file3.txt']

      it 'unzips the files and stores them in the given location' do
        expect(File.exist?(File.join(@destination, expected_filenames.first))
              ).to eq(false), 'Precondition of test not met: File already exists'
        expect(File.exist?(File.join(@destination, expected_filenames.second))
              ).to eq(false), 'Precondition of test not met: File already exists'
        expect(File.exist?(File.join(@destination, expected_filenames.third))
              ).to eq(false), 'Precondition of test not met: File already exists'
        subject.class.unzip(zip_file, @destination)
        expect(File.exist?(File.join(@destination, expected_filenames.first))).to eq(true)
        expect(File.exist?(File.join(@destination, expected_filenames.second))).to eq(true)
        expect(File.exist?(File.join(@destination, expected_filenames.third))).to eq(true)
      end
    end
  end

  describe '::unzip_deposit_file' do
    after(:example) do
      FileUtils.rm_rf(@deposit_dir.delete_suffix('contents'))
    end

    context 'When receiving request body' do
      it 'creates the directory to store the unzipped files' do
        allow(described_class).to receive(:unzip)
        request_body = StringIO.new('This is the test text string')
        @deposit_dir = subject.class.unzip_deposit_file request_body
        expect(@deposit_dir).to include 'tmp'
      end
    end
  end
end
