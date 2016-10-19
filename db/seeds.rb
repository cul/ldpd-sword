SEEDS_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/seeds.yml")[Rails.env])

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

collections = {}
SEEDS_CONFIG[:collections].each do |key, info|
  collections[key] = Collection.create(name: info[:name],
                                       slug: info[:slug],
                                       atom_title: info[:atom_title],
                                       hyacinth_project_string_key: info[:hyacinth_project_string_key],
                                       parser: info[:parser])
end

depositors = {}
SEEDS_CONFIG[:depositors].each do |key, info|
  depositors[key] = Depositor.create(name: info[:name],
                                     basic_authentication_user_id: info[:basic_authentication_user_id],
                                     password: info[:password],
                                     password_confirmation: info[:password_confirmation])
end

SEEDS_CONFIG[:depositor_collection_pairings].each do |key, info|
  depositors[info[:depositor]].collections << collections[info[:collection]]
end


