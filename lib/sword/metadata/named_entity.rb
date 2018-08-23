module Sword
  module Metadata
    class NamedEntity
      attr_accessor :corporate_name,
                    :first_name,
                    :full_name_naf_format,
                    :last_name,
                    :middle_name,
                    :role,
                    # following is similar to type for mods:name,
                    # so personal or corporate in most cases
                    :type,
                    :uni
    end
  end
end
