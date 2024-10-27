COLLECTIONS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/collections.yml")[Rails.env]).freeze
DEPOSITORS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/depositors.yml")[Rails.env]).freeze
HYACINTH_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/hyacinth.yml")[Rails.env]).freeze
METADATA_VALUES = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/metadata.yml"))
PROQUEST_FAST_MAP = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/proquest_fast_map.yml")).freeze
