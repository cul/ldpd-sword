class DropCollections < ActiveRecord::Migration[7.2]
  def change
    remove_index :collections, :name, unique: true
    remove_index :collections, :slug, unique: true  
    drop_table :collections do |t|
      t.string :name, null: false
      t.string :atom_title, null: false
      t.string :slug, null: false
      t.string :hyacinth_project_string_key
      t.string :parser
      t.text :abstract
      t.text :mime_types
      t.text :sword_package_types
      t.boolean :mediation_enabled, default: false

      t.timestamps null: false
    end
  end
end
