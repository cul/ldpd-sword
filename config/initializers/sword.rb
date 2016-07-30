SWORD_CONFIG = YAML.load_file("#{Rails.root}/config/sword.yml")[Rails.env]
puts SWORD_CONFIG.inspect if Rails.env.development?
