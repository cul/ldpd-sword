class AddUserIdAndCollectionSlugToDeposits < ActiveRecord::Migration[4.2]
  def change
    add_column :deposits, :depositor_user_id, :string
    add_index :deposits, :depositor_user_id
    add_column :deposits, :collection_slug, :string
    add_index :deposits, :collection_slug
  end
end
