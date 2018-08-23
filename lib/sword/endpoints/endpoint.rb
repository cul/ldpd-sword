module Sword
  module Endpoints
    class Endpoint

      attr_reader :collection
      attr_reader :depositor
      attr_reader :documents_to_deposit
      attr_reader :deposit_title
      attr_reader :adapter_item_identifier

      def initialize(collection, depositor)
        @collection = collection
        @depositor = depositor
      end

      def self.get_endpoint(collection,
                            depositor)
        case collection.parser
        when "academic-commons"
          Sword::Endpoints::AcademicCommonsEndpoint.new(collection, depositor)
        when "proquest"
          Sword::Endpoints::ProquestEndpoint.new(collection, depositor)
        when "springer-nature"
          Sword::Endpoints::SpringerNatureEndpoint.new(collection, depositor)
        else
          # raise an exception here
        end
      end
    end
  end
end
