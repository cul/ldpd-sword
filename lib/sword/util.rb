module Sword
  require 'zip'
  # fcd1, 07/16/18: Possibly make this a module
  class Util
    CONTENTS_SUBDIR = 'contents'
    DEPOSIT_FILENAME = 'deposit.zip'
    def self.unzip_deposit_file post_request
      Rails.logger.warn("About to sleep for 2 seconds")
      sleep(2)
      Rails.logger.warn("Done sleeping for 2 seconds")
      save_path = File.join(SWORD_CONFIG[:unzip_dir],"tmp_#{Time.now.to_i}")
      FileUtils.mkdir_p(save_path) unless File.directory?(save_path)
      zip_file = File.join(save_path, DEPOSIT_FILENAME)
      File.open(zip_file, "wb") { |file| file.write(post_request.body.read) }
      path_to_contents = File.join(save_path, CONTENTS_SUBDIR)
      # create directory where contents of zip file will be saved
      Dir.mkdir path_to_contents
      Sword::Util::unzip(zip_file,
                         path_to_contents)
      path_to_contents
    end

    def self.unzip(filename_with_path, destination_path)
      Zip::File.open(filename_with_path).each do |file|
        file.extract(File.join(destination_path,file.name))
      end
    end
  end
end
