class CreateUserPageRelationships < ActiveRecord::Migration
  def change
    create_table :user_page_relationships do |t|
      t.integer :user_id
      t.integer :page_id

      t.timestamps
    end
    
    add_index :user_page_relationships, :user_id
    add_index :user_page_relationships, :page_id
    add_index :user_page_relationships, [:user_id, :page_id], unique: true
  end
end
