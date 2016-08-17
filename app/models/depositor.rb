class Depositor < ActiveRecord::Base
  has_many :deposits
  has_many :depositor_collection_permissions
  has_many :collections, through: :depositor_collection_permissions
end
