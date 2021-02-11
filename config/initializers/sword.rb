SWORD_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/sword.yml")[Rails.env]).freeze
METADATA_VALUES = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/metadata.yml")).freeze
HYACINTH_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/hyacinth.yml")[Rails.env]).freeze
PROQUEST_FAST_MAP = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/proquest_fast_map.yml")).freeze
DEPOSITORS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/depositors.yml")[Rails.env]).freeze
COLLECTIONS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/collections.yml")[Rails.env]).freeze
FileUtils.mkdir_p(SWORD_CONFIG[:unzip_dir]) unless File.directory?(SWORD_CONFIG[:unzip_dir])
FileUtils.mkdir_p(HYACINTH_CONFIG[:payload_dir]) unless File.directory?(HYACINTH_CONFIG[:payload_dir])
