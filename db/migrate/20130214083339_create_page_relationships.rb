class CreatePageRelationships < ActiveRecord::Migration
  def change
    create_table :page_relationships do |t|
      t.integer :follower_id
      t.integer :competitor_id

      t.timestamps
    end
    
    add_index :page_relationships, :follower_id
    add_index :page_relationships, :competitor_id
    add_index :page_relationships, [:follower_id, :competitor_id], unique: true
  end
end
