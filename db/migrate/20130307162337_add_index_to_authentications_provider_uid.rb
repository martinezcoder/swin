class AddIndexToAuthenticationsProviderUid < ActiveRecord::Migration
  def change
    add_index :authentications, [:provider, :uid]
  end
end
