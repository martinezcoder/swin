class CreateFbTopEngages < ActiveRecord::Migration
  def change
    create_table :fb_top_engages do |t|
      t.integer :day
      t.integer :page_id
      t.integer :page_fb_id
      t.integer :engagement
      t.integer :variation

      t.timestamps
    end
  end
end
