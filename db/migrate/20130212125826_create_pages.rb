class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :page_id
      t.string :name
      t.string :type
      t.string :username
      t.string :page_url
      t.string :pic_square

      t.timestamps
    end
    add_index :pages, :page_id, unique: true
  end
end
