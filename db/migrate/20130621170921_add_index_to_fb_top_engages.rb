class AddIndexToFbTopEngages < ActiveRecord::Migration
  def change
    add_index :fb_top_engages, :day
    add_index :fb_top_engages, :page_id
  end
end
