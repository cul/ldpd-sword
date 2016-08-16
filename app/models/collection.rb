class Collection < ActiveRecord::Base
  # fcd1, 07/26/16: Remove this if decide to use a MimeType table instead, though don't think will go the table way
  serialize :mime_types, Array
  serialize :sword_package_types, Array
  has_many :depositor_collection_permissions
  has_many :depositors, through: :depositor_collection_permissions
end
