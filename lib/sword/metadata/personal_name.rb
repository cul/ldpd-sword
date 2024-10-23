# frozen_string_literal: true

module Sword
  module Metadata
    class PersonalName
      include ActiveModel::Model
      include ActiveModel::Attributes
      attribute :first_name, :string
      attribute :full_name_naf_format, :string
      attribute :last_name, :string
      attribute :middle_name, :string
      attribute :role, :string
      # type can be primary, alternate, etc. Kinda freeform
      attribute :type, :string
      attribute :uni, :string
    end
  end
end
