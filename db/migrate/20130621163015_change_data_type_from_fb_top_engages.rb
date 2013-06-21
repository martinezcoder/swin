class ChangeDataTypeFromFbTopEngages < ActiveRecord::Migration
  def up
    change_column :fb_top_engages, :page_fb_id, :string
  end

  def down
    change_column :fb_top_engages, :page_fb_id, :integer
  end
end
