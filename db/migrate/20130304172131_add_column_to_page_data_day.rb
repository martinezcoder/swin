class AddColumnToPageDataDay < ActiveRecord::Migration
  def change
    add_column :page_data_days, :posts, :integer
  end
end
