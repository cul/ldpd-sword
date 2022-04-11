class RemoveAbstractFromDeposits < ActiveRecord::Migration[4.2]
  def change
    remove_column :deposits, :abstract, :text
  end
end
