# require "deposits/sword"
require "sword/parsers/proquest_parser"
require 'zip'
module Sword
module DepositUtils
  
  def self.unpackZip(zipFile, destinationPath)
    puts zipFile
    destinationPath = destinationPath + '/'
    Zip::File.open(zipFile) { |zip|
      zip.each { |file|
        filePpath=File.join(destinationPath, file.name)
        FileUtils.mkdir_p(File.dirname(filePpath))
        zip.extract(file, filePpath) unless File.exist?(filePpath)
      }
    }
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
      Sword::Parsers::ProquestParser.new
    else
      # raise an exception here
    end
  end

  def self.xml_file
    File.open('/tmp/sword/mets.xml')
  end
end
end
