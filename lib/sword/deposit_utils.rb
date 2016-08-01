require "deposits/sword"
require 'zip/zipfilesystem'
require 'zip/zip'
module Sword
module DepositUtils
  
  def self.unpackZip(zipFile, destinationPath)
    
    Zip::ZipFile.open(zipFile) { |zip|
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

end
end
