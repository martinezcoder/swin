class ChangeDataTypeFromPage < ActiveRecord::Migration
  def up
    change_column :pages, :pic_square, :text
    change_column :pages, :pic_big,    :text
  end

  def down
    change_column :pages, :pic_square, :string
    change_column :pages, :pic_big,    :string
  end
end
