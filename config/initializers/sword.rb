SWORD_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/sword.yml", aliases: true)[Rails.env]).freeze
METADATA_VALUES = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/metadata.yml", aliases: true)).freeze
HYACINTH_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/hyacinth.yml", aliases: true)[Rails.env]).freeze
PROQUEST_FAST_MAP = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/proquest_fast_map.yml", aliases: true)).freeze
DEPOSITORS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/depositors.yml", aliases: true)[Rails.env]).freeze
COLLECTIONS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/collections.yml", aliases: true)[Rails.env]).freeze
FileUtils.mkdir_p(SWORD_CONFIG[:unzip_dir]) unless File.directory?(SWORD_CONFIG[:unzip_dir])
FileUtils.mkdir_p(HYACINTH_CONFIG[:payload_dir]) unless File.directory?(HYACINTH_CONFIG[:payload_dir])
