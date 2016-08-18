class CreateDepositors < ActiveRecord::Migration
  def change
    create_table :depositors do |t|
      t.string :name, null: false
      t.string :basic_authentication_user_id, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end
    add_index :depositors, :name, unique: true
    add_index :depositors, :basic_authentication_user_id, unique: true
  end
end
