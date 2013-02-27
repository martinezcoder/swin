class CreatePageDataDays < ActiveRecord::Migration
  def change
    create_table :page_data_days do |t|
      t.integer :page_id
      t.date :date
      t.integer :likes
      t.integer :prosumers
      t.integer :comments
      t.integer :shared
      t.integer :avg_likes_comment

      t.timestamps
    end
    add_index :page_data_days, [:page_id, :date], unique: true
  end
end
