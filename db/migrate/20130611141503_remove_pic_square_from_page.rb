class RemovePicSquareFromPage < ActiveRecord::Migration
  def up
    remove_column :pages, :pic_square
    remove_column :pages, :pic_big
  end

  def down
    add_column :pages, :pic_square, :text
    add_column :pages, :pic_big, :text
  end
end
