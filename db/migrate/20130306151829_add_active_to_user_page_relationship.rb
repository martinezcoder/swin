class AddActiveToUserPageRelationship < ActiveRecord::Migration
  def change
    add_column :user_page_relationships, :active, :boolean, default: false
  end
end
