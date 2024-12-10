class AddIngestConfirmedToDeposits < ActiveRecord::Migration[7.2]
  def change
    add_column :deposits, :ingest_confirmed, :boolean
  end
end
