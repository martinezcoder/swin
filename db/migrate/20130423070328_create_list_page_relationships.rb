class CreateListPageRelationships < ActiveRecord::Migration
  def change
    create_table :list_page_relationships do |t|
      t.integer :list_id
      t.integer :page_id

      t.timestamps
    end

    add_index :list_page_relationships, :list_id
    add_index :list_page_relationships, :page_id
    add_index :list_page_relationships, [:list_id, :page_id], unique: true

  end
end
