module Sword
  module Metadata
    class ModsName
      attr_accessor :id,
                    :name_part,
                    :role,
                    :type
      class Role
        attr_accessor :role_term,
                      :role_term_authority,
                      :role_term_type,
                      :role_term_value_uri
      end

      def initialize
        @role = Role.new
      end
    end
  end
end
