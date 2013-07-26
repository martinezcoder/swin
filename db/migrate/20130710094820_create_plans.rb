class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :num_competitors
      t.integer :num_lists
      t.float :price

      t.timestamps
    end
    
     add_index :plans, :name, unique: true
     
  end
end
