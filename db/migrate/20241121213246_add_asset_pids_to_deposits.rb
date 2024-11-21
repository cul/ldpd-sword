class AddAssetPidsToDeposits < ActiveRecord::Migration[7.2]
  def change
    add_column :deposits, :asset_pids, :text
  end
end
