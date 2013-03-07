class ImproveIndexesDefinition < ActiveRecord::Migration

  def change

    # page_data_days
    add_index :page_data_days, :page_id
    add_index :page_data_days, :day

    # page_streams
    remove_index  :page_streams, [:page_id, :created_time]
    remove_index  :page_streams, :created_time
    add_index     :page_streams, :day
    add_index     :page_streams, :media_type
    add_index     :page_streams, [:page_id, :media_type]
  end
end
