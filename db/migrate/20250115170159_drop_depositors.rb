class DropDepositors < ActiveRecord::Migration[7.2]
  def change
    remove_index :depositors, :name, unique: true
    remove_index :depositors, :basic_authentication_user_id, unique: true
    drop_table :depositors do |t|
      t.string :name, null: false
      t.string :basic_authentication_user_id, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end
  end
end
