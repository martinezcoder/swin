class CreatePageStreams < ActiveRecord::Migration
  def change
    create_table :page_streams do |t|
      t.integer :page_id
      t.string :post_id
      t.string :permalink
      t.string :media_type
      t.string :actor_id
      t.string :target_id
      t.integer :likes_count
      t.integer :comments_count
      t.integer :share_count
      t.integer :created_time
      t.integer :updated_time

      t.timestamps
    end
    add_index :page_streams, [:page_id]
    add_index :page_streams, [:page_id, :created_time], unique: true
    add_index :page_streams, [:created_time]
    add_index :page_streams, [:actor_id]    
  end
end
