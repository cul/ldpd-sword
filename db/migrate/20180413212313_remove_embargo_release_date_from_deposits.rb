class RemoveEmbargoReleaseDateFromDeposits < ActiveRecord::Migration[4.2]
  def change
    remove_column :deposits, :embargo_release_date, :datetime
  end
end
