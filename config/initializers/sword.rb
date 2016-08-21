SWORD_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/sword.yml")[Rails.env])
FileUtils.mkdir_p(SWORD_CONFIG[:unzip_dir]) unless File.directory?(SWORD_CONFIG[:unzip_dir])
puts SWORD_CONFIG.inspect if Rails.env.development?
