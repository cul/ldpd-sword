class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.belongs_to :sword_deposit, index: true, foreign_key: true
      t.string :filename, null: false
      t.text :contents
      t.string :filepath

      t.timestamps null: false
    end
  end
end
