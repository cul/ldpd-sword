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
end

