class RemoveForeignKeysDeposits < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key "deposits", "collections"
    remove_foreign_key "deposits", "depositors"
  end
end
