class CreateResourceInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table :resource_interactions, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :user_id, limit: 36, null: false
      t.string :resource_id, limit: 36, null: false
      t.string :interaction_type, limit: 50, null: false

      t.timestamps
    end

    add_foreign_key :resource_interactions, :users, column: :user_id
    add_foreign_key :resource_interactions, :resources, column: :resource_id
    add_index :resource_interactions, :user_id
    add_index :resource_interactions, :resource_id
    add_index :resource_interactions, :interaction_type
  end
end