module Sword
  module Endpoints
    class Endpoint

      attr_reader :collection
      attr_reader :depositor
      attr_reader :documents_to_deposit
      attr_reader :deposit_title
      attr_reader :adapter_item_identifier

      # depositor_user_id represents the user part of the basic authentication
      # in the HTTP POST request
      def initialize(collection_slug, depositor_user_id)
        @collection_slug = collection_slug
        @depositor_user_id = depositor_user_id
      end
    end
  end
end
