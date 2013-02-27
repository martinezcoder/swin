class AddFanCountToPages < ActiveRecord::Migration
  def change
    add_column :pages, :fan_count, :integer
  end
end
