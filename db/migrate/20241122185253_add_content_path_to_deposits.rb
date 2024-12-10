class AddContentPathToDeposits < ActiveRecord::Migration[7.2]
  def change
    add_column :deposits, :content_path, :string
  end
end
