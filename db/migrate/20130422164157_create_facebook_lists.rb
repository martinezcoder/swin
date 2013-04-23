class CreateFacebookLists < ActiveRecord::Migration
  def change
    create_table :facebook_lists do |t|
      t.references :user
      
      t.string :name
      t.string :photo_url

      t.timestamps
    end
    add_index :facebook_lists, [:user_id, :created_at]
  end
end
