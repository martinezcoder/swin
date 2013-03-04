class AddColumnToPageDataDayDay < ActiveRecord::Migration
  def change
    remove_index  :page_data_days, [:page_id]
    
    add_column :page_data_days, :day, :integer
    add_index :page_data_days, [:page_id, :day], unique: true
  end
end
