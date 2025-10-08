class CreateUserSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_settings, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :user_id, limit: 36, null: false
      t.string :setting_key, limit: 100, null: false
      t.text :setting_value

      t.timestamps
    end

    add_foreign_key :user_settings, :users, column: :user_id
    add_index :user_settings, :user_id
    add_index :user_settings, [:user_id, :setting_key], unique: true, name: 'index_user_settings_unique'
  end
end