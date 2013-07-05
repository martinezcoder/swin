class RemovePageUrlFromPage < ActiveRecord::Migration
  def up
    remove_column :pages, :page_url
  end

  def down
    add_column :pages, :page_url, :string
  end
end
