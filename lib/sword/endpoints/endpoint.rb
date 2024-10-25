# frozen_string_literal: true

module Sword::Endpoints::Endpoint
  attr_reader :collection,
              :depositor,
              :documents_to_deposit,
              :deposit_title,
              :adapter_item_identifier,
              :collection_slug

  # depositor_user_id represents the user part of the basic authentication
  # in the HTTP POST request
  def initialize(collection_slug, depositor_user_id)
    @collection_slug = collection_slug
    @depositor_user_id = depositor_user_id
  end
end
