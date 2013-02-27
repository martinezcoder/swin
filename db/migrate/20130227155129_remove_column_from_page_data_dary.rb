class RemoveColumnFromPageDataDary < ActiveRecord::Migration
  def change
    remove_index :page_data_days, [:page_id, :date]
    add_index   :page_data_days, [:page_id], unique: true
    
    remove_column :page_data_days, :date

    rename_column :page_data_days, :avg_likes_comment, :total_likes_stream
  end

end
