# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Collection.create(name: "A Collection", slug: "a-collection")
Collection.create(name: "Another Collection",slug: "another-collection")

Depositor.create(name: "First Depositor",
                 basic_authentication_user_id: "firstdid",
                 basic_authentication_password: "firstdpasswd")

Depositor.create(name: "Second Depositor",
                 basic_authentication_user_id: "seconddid",
                 basic_authentication_password: "secondpasswd")

