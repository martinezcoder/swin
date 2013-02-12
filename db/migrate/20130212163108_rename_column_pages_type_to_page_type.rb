class RenameColumnPagesTypeToPageType < ActiveRecord::Migration
  def up
    rename_column :pages, :type, :page_type
  end

  def down
  end
end
