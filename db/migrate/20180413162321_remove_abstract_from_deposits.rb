class RemoveAbstractFromDeposits < ActiveRecord::Migration
  def change
    remove_column :deposits, :abstract, :text
  end
end
