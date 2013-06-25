class AddIndexToFbTopEngagement < ActiveRecord::Migration
  def change
    add_index :fb_top_engages, [:day, :page_id], unique: true
  end
end
