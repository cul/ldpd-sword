# require "deposits/sword"
require "sword/parsers/proquest_parser"
require "sword/parsers/bmc_parser"
require 'zip'
module Sword
module DepositUtils
  
  def self.unpackZip(zipFile, destinationPath)
    # puts zipFile
    destinationPath = destinationPath + '/'
    Zip::File.open(zipFile) { |zip|
      zip.each { |file|
        filePpath=File.join(destinationPath, file.name)
        FileUtils.mkdir_p(File.dirname(filePpath))
        zip.extract(file, filePpath) unless File.exist?(filePpath)
      }
    }
  end
  
  def self.process_package_file(content, file_name)
    save_path = File.join(SWORD_CONFIG[:unzip_dir],"tmp_#{Time.now.to_i}")
    FileUtils.mkdir_p(save_path) unless File.directory?(save_path)
    
    zip_file = File.join(save_path, file_name)
    # puts "!!!!!!!!!!!!!!!!!! Filepath !!!!!!!!!!!!!!!!!"
    # puts zip_file
    File.open(zip_file, "wb") { |file| file.write(content) }
    unpackZip(zip_file,
              File.join(save_path,SWORD_CONFIG[:contents_zipfile_subdir]))
    save_path
  end

  # fcd1, 08/22/16: Original code came from lib/deposits/sword/sword_tools.rb in hypatia-new
  # Made tweaks to it
  # def self.getAllFilesList(sword_pid)
  def self.getAllFilesList(path)
    mets = Nokogiri::XML(File.read(File.join(path,'mets.xml')))
    files = []
    mets.css("FLocat[@LOCTYPE='URL']").each do |file_node|
      file = file_node["href"]
      if(file == nil)
        file = file_node["xlink:href"]
      end
      files.push(file)
    end
    return files   
  end

  def self.cp_files_to_hyacinth_upload_dir(zip_file_path, filenames)

    filenames.each do |file|
      FileUtils.cp( File.join(zip_file_path,
                              SWORD_CONFIG[:contents_zipfile_subdir],
                              file
                              ),
                    File.join(HYACINTH_CONFIG[:upload_directory],
                              file
                              )
                    )
    end
  end

  def self.removeDir(directory)
    FileUtils.remove_dir(directory, force = false)
  end
  
  def self.removeDir(directory, trash_dir)
    
    Rails.logger.info "============= directory: " + directory
    Rails.logger.info "============= trash_dir: " + trash_dir
    
   FileUtils.remove_dir(directory, force = true) # This method ignores StandardError if force is true.
   FileUtils.remove_dir(trash_dir, force = true) 
   if(File.directory?(directory))
    FileUtils.mv(directory, trash_dir)
   end
  end  
  
  
  
  def self.getExportedPid(item_id)      

    exports = []
    conditions = ["item_id = ? AND options.value = ?",item_id,'Aggregator']
    Export.find(:all, :conditions => conditions, :include => :options).each do |exp|
      exp.options.each do |op|
        exports << [op.name, exp.created_at]
      end
    end

    return exports
  end
  
  def self.getExportedPids(item_id)   
       
    exports = []
    conditions = {:item_id => item_id}
    Export.find(:all, :conditions => conditions, :include => :options).each do |exp|
      exp.options.each do |op|
        exports << [op.name, op.value, exp.created_at]
      end
    end
    exports.sort! {|a,b| a[1] <=> b[1]}
    return exports
  end  

  # fcd1, 08/19/16: in hypatia-new, #save_file was defined in app/helpers/sword_helper.rb
  # The version here has been tweaked.
  # probably want to have this method return the path to the zip file, which 
  # should vary for each deposit to prevent overwriting. See how hypatia-new handles it
  # for now, just /tmp/sword, as set in sword.yml
  def self.save_file(content, file_name, save_path)
    
    FileUtils.mkdir_p(save_path) unless File.directory?(save_path)
    
    file = save_path + '/' + file_name
    
    # logger.info "file full path: " + file
    
    begin
      file = File.open(file, "wb")
      file.write(content)
    rescue IOError => e
      # logger.info "========= ERROR writing file ========== : " + e.to_s
      raise
    ensure
      file.close unless file == nil
    end
    
  end

  # fcd1, 08/20/16: Possibly move this into a (needs to be written) parent class for all Parsers, make it a
  # class method.
  def self.getParser parser_name
    case parser_name
    when "proquest"
      Sword::Parsers::ProquestParser.new
    when "bmc"
      Sword::Parsers::BmcParser.new
    else
      # raise an exception here
    end
  end

  def self.xml_file
    File.open('/tmp/sword/mets.xml')
  end

  # fcd1, 08/21/16: Original code came from lib/deposits/sword/sword_tools.rb in hypatia-new
  # Not sure if I'm gonna use it, and it may need tweaks
  def self.download(sword_pid)
    zip_dir = SwordTools.makeZipPath(sword_pid)

    FileUtils.mkdir_p(zip_dir) unless File.directory?(zip_dir)
    swordZipFile = zip_dir + SwordTools.normalizePid(sword_pid) + '.zip'

    # download
    open(swordZipFile, 'wb') do |file|
      file << open(SwordTools.getSwordConfig['fedora_source_base'] + sword_pid + '/datastreams/content/content').read
    end

    # unzip
    Zip::ZipFile.open(swordZipFile) { |zip_file|
      zip_file.each { |f|
        f_path=File.join(zip_dir, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }

  end

  # fcd1, 08/21/16: Original code came from lib/deposits/sword/sword_tools.rb in hypatia-new
  # Not sure if I'm gonna use it, and it may need tweaks
 def self.makeZipPath(sword_pid)

    normilizedPid = SwordTools.normalizePid(sword_pid)
    base_dir = SwordTools.getSwordConfig['tmp_base']
    zip_dir = base_dir + normilizedPid + "/"
    return zip_dir
 end

  # fcd1, 08/21/16: Original code came from lib/deposits/sword/sword_tools.rb in hypatia-new
  # Not sure if I'm gonna use it, and it may need tweaks
  def self.removeDownloadedFiles(sword_pid)
    #FileUtils.remove_dir(SwordTools.makeZipPath(sword_pid))
    command = "rm -rf " + SwordTools.makeZipPath(sword_pid)
    system command
  end
end
end
