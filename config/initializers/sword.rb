SWORD_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/sword.yml")[Rails.env]).freeze
METADATA_VALUES = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/metadata.yml")).freeze
HYACINTH_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/hyacinth.yml")[Rails.env]).freeze
PROQUEST_FAST_MAP = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/proquest_fast_map.yml")).freeze
FileUtils.mkdir_p(SWORD_CONFIG[:unzip_dir]) unless File.directory?(SWORD_CONFIG[:unzip_dir])
