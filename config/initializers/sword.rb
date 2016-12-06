SWORD_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/sword.yml")[Rails.env])
HYACINTH_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/hyacinth.yml")[Rails.env])
PROQUEST_FAST_MAP = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/proquest_fast_map.yml"))
FileUtils.mkdir_p(SWORD_CONFIG[:unzip_dir]) unless File.directory?(SWORD_CONFIG[:unzip_dir])
