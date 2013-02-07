class AddApprovedPolicyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :approved_policy, :boolean, default: false
  end
end
