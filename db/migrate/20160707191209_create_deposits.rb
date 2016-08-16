class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.belongs_to :depositor, index: true, foreign_key: true
      t.belongs_to :collection, index: true, foreign_key: true
      t.string :title
      t.string :item_in_hyacinth
      t.datetime :embargo_release_date
      t.integer :status, null: false, index: true, default: 0
      t.text :deposit_errors
      t.string :header_content_type
      t.string :header_content_md5
      t.string :header_user_agent
      t.string :header_content_disposition_filename
      t.string :header_x_on_behalf_of
      t.boolean :header_x_verbose, default: false
      t.boolean :header_x_no_op, default: false

      t.timestamps null: false
    end
  end
end
