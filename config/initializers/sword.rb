SWORD_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/sword.yml")[Rails.env])
# unzip_dir = "#{Rails.root}/#{SWORD_CONFIG[:unzip_dir]}"
unzip_dir =  Rails.root.join(SWORD_CONFIG[:unzip_dir])
puts unzip_dir
FileUtils.mkdir_p(unzip_dir) unless File.directory?(unzip_dir)
puts SWORD_CONFIG.inspect if Rails.env.development?
