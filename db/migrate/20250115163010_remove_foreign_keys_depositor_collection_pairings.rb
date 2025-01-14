class RemoveForeignKeysDepositorCollectionPairings < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key "depositor_collection_pairings", "collections"
    remove_foreign_key "depositor_collection_pairings", "depositors"
  end
end
