# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

first_collection = Collection.create(name: "First Collection", slug: "first-collection")
second_collection =Collection.create(name: "Second Collection",slug: "second-collection")

first_depositor = Depositor.create(name: "First Depositor",
                                   basic_authentication_user_id: "firstdid",
                                   basic_authentication_password: "firstdpasswd")

second_depositor = Depositor.create(name: "Second Depositor",
                                    basic_authentication_user_id: "seconddid",
                                    basic_authentication_password: "secondpasswd")

first_depositor.collections << first_collection
first_depositor.collections << second_collection
second_depositor.collections << second_collection
