class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
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
    add_index :collections, :name, unique: true
    add_index :collections, :slug, unique: true
  end
end
