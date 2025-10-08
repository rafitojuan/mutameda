class CreateTriggers < ActiveRecord::Migration[8.0]
  def change
    create_table :triggers, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :name, limit: 100, null: false
      t.string :category, limit: 50, null: false
      t.string :color_code, limit: 7, default: '#6c757d'
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :triggers, :category
    add_index :triggers, :is_active
  end
end