class AddPageIdToFacebookLists < ActiveRecord::Migration
  def change
    add_column :facebook_lists, :page_id, :integer

    add_index :facebook_lists, :page_id
  end

end
