class CreateUserPlanRelationships < ActiveRecord::Migration
  def change
    create_table :user_plan_relationships do |t|
      t.integer :user_id
      t.integer :plan_id
      t.integer :effective_date
      t.integer :expiration_date

      t.timestamps
    end

    add_index :user_plan_relationships, :user_id
    add_index :user_plan_relationships, :plan_id
    add_index :user_plan_relationships, :effective_date
    add_index :user_plan_relationships, :expiration_date

  end
end
