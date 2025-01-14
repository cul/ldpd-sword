SEEDS_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/seeds.yml", aliases: true)[Rails.env])

admins = {}
# Since the creation of seeded user accounts (admin and non-admin)
# requires credentials which should not be stored in github, the credentials 
# are kept in the sword.yml config file
SEEDS_CONFIG[:admin_users].each do |key, info|
  admins[key] = User.create(email: info[:email],
                            name: info[:name],
                            admin: true,
                            password: info[:password],
                            password_confirmation: info[:password])
end

non_admins = {}
# Since the creation of seeded user accounts (admin and non-admin)
# requires credentials which should not be stored in github, the credentials 
# are kept in the sword.yml config file
SEEDS_CONFIG[:non_admin_users].each do |key, info|
  non_admins[key] = User.create(email: info[:email],
                                name: info[:name],
                                admin: true,
                                password: info[:password],
                                password_confirmation: info[:password])
end
