class RenameUpdateTimeFromPageStream < ActiveRecord::Migration
  def change
    rename_column :page_streams, :updated_time, :day
    add_index :page_streams, [:page_id, :day]
  end
end
