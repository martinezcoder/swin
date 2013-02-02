class AddIndexToAuthenticationsUserProvider < ActiveRecord::Migration
  def change
    add_index :authentications, [:user_id, :provider], unique: true
  end
end
