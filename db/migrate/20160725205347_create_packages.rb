class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :filename
      t.text :contents
      t.string :filepath

      t.timestamps null: false
    end
  end
end
