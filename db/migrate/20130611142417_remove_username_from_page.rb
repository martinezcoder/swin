class RemoveUsernameFromPage < ActiveRecord::Migration
  def up
    remove_column :pages, :username
  end

  def down
    add_column :pages, :username, :string
  end
end
