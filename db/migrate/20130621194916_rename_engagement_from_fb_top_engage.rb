class RenameEngagementFromFbTopEngage < ActiveRecord::Migration
  def change
    rename_column :fb_top_engages, :engagement, :fan_count
    add_column :fb_top_engages, :talking_about_count, :integer
  end
end
