class Collection < ActiveRecord::Base
  validates :name, presence: true
  validates :atom_title, presence: true
  validates :slug, presence: true
  serialize :mime_types, Array
  serialize :sword_package_types, Array
  has_many :deposits
  has_many :depositor_collection_permissions
  has_many :depositors, through: :depositor_collection_permissions
end
