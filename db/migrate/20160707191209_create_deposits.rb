class CreateDeposits < ActiveRecord::Migration[4.2]
  def change
    create_table :deposits do |t|
      t.belongs_to :depositor, index: true, foreign_key: true
      t.belongs_to :collection, index: true, foreign_key: true
      t.string :title
      t.text :abstract
      t.string :item_in_hyacinth
      t.datetime :embargo_release_date
      t.integer :status, null: false, index: true, default: 0
      t.text :deposit_files
      t.text :deposit_errors

      t.timestamps null: false
    end
  end
end
