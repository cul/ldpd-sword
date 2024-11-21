FactoryBot.define do
  factory :deposit do
    title { "This is a factory title" }
    item_in_hyacinth  { "ac:123456789" }
    collection_slug { "test-pq" }
    depositor_user_id { "depositor_user_id" }
  end
end
