# require "deposits/sword"
require 'zip'
module Sword
module DepositUtils
  
  def self.unpackZip(zipFile, destinationPath)
    
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

end
end
