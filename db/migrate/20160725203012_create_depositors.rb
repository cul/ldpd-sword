class CreateDepositors < ActiveRecord::Migration
  def change
    create_table :depositors do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :depositors, :name, unique: true
  end
end
