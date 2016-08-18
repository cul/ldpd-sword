if Rails.env.development?
  first_dev_collection = Collection.create(name: "First Dev Collection",
                                       slug: "first-dev-collection",
                                       atom_title: "Atom Title of First Dev Collection",
                                       abstract: "This is the abstract for the First Dev Collection",
                                       mime_types: ["application/zip", "application/pdf"],
                                       sword_package_types: ["http://purl.org/net/sword-types/METSDSpaceSIP",
                                                             "http://purl.org/net/sword-types/mets/dspace"])

  second_dev_collection =Collection.create(name: "Second Dev Collection",
                                       slug: "second-dev-collection",
                                       atom_title: "Atom Title of Second Dev Collection")

  first_dev_depositor = Depositor.create(name: "First Dev Depositor",
                                         basic_authentication_user_id: "firstdid",
                                         password: "firstdpasswd",
                                         password_confirmation: "firstdpasswd")

  second_dev_depositor = Depositor.create(name: "Second Dev Depositor",
                                          basic_authentication_user_id: "seconddid",
                                          password: "secondpasswd",
                                          password_confirmation: "secondpasswd")

  first_dev_depositor.collections << first_dev_collection
  first_dev_depositor.collections << second_dev_collection
  second_dev_depositor.collections << second_dev_collection
end

