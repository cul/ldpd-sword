class RemoveEmbargoReleaseDateFromDeposits < ActiveRecord::Migration
  def change
    remove_column :deposits, :embargo_release_date, :datetime
  end
end
