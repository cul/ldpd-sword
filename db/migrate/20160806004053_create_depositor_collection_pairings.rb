class CreateDepositorCollectionPairings < ActiveRecord::Migration[4.2]
  def change
    create_table :depositor_collection_pairings do |t|
      t.belongs_to :depositor, index: true, foreign_key: true
      t.belongs_to :collection, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
