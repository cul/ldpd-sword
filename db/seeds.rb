SEEDS_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/seeds.yml")[Rails.env])
if Rails.env.development?
  first_collection = Collection.create(name: "First Collection (Proquest)",
                                       slug: "first-collection-pro",
                                       atom_title: "Atom Title of First Collection",
                                       hyacinth_project_string_key: "academic_commons",
                                       parser: "proquest",
                                       abstract: "This is the abstract for the First Collection",
                                       mime_types: ["application/zip", "application/pdf"],
                                       sword_package_types: ["http://purl.org/net/sword-types/METSDSpaceSIP",
                                                             "http://purl.org/net/sword-types/mets/dspace"])

  second_collection = Collection.create(name: "Second Collection (BMC)",
                                        slug: "second-collection-bmc",
                                        atom_title: "Atom Title of Second Collection",
                                        hyacinth_project_string_key: "academic_commons",
                                        parser: "bmc")

  third_collection = Collection.create(name: "Third Collection",
                                       slug: "third-collection",
                                       atom_title: "Atom Title of Third Collection",
                                       hyacinth_project_string_key: "first_project",
                                       parser: "bmc")

  first_depositor = Depositor.create(name: "First Depositor (Proquest)",
                                     basic_authentication_user_id: "firstdid",
                                     password: "firstdpasswd",
                                     password_confirmation: "firstdpasswd")

  second_depositor = Depositor.create(name: "Second Depositor (BMC)",
                                      basic_authentication_user_id: "seconddid",
                                      password: "seconddpasswd",
                                      password_confirmation: "seconddpasswd")

  first_depositor.collections << first_collection
  second_depositor.collections << second_collection
  first_depositor.collections << third_collection

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
end

if Rails.env.sword_dev?
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
end

