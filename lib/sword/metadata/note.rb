module Sword
  module Metadata
    class Note
      attr_accessor :content,
                    :type

      def initialize(content, type = nil)
        @content = content
        @type = type
      end
    end
  end
end
