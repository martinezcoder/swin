class AddDateRangeToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :max_date_range, :integer
  end
end
