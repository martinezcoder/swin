class AddPicBigToPages < ActiveRecord::Migration
  def change
    add_column :pages, :pic_big, :string
  end
end
