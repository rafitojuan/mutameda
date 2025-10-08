class CreateResources < ActiveRecord::Migration[8.0]
  def change
    create_table :resources, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :title, limit: 255, null: false
      t.text :content
      t.string :category, limit: 50, null: false
      t.string :resource_type, limit: 50, null: false
      t.string :external_url, limit: 500
      t.boolean :is_published, default: true

      t.timestamps
    end

    add_index :resources, :category
    add_index :resources, :resource_type
    add_index :resources, :is_published
  end
end