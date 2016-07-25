class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.belongs_to :depositor, index: true, foreign_key: true
      t.belongs_to :collection, index: true, foreign_key: true
      t.string :title
      t.string :on_behalf_of
      t.string :item_in_hyacinth
      t.datetime :embargo_release_date
      t.integer :status
      t.text :errors

      t.timestamps null: false
    end
  end
end
