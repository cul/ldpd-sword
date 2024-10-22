# frozen_string_literal: true

module Sword
  module Metadata
    class PersonalName
      attr_accessor :first_name,
                    :full_name_naf_format,
                    :last_name,
                    :middle_name,
                    :role,
                    # type can be primary, alternate, etc. Kinda freeform
                    :type,
                    :uni
    end
  end
end
