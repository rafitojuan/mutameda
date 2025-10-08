class CreateMoodEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :mood_entries, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :user_id, limit: 36, null: false
      t.integer :mood_level, null: false
      t.integer :energy_level
      t.integer :sleep_quality
      t.integer :anxiety_level
      t.integer :stress_level
      t.text :notes
      t.datetime :logged_at, null: false

      t.timestamps
    end

    add_foreign_key :mood_entries, :users, column: :user_id
    add_index :mood_entries, :user_id
    add_index :mood_entries, :logged_at
    add_index :mood_entries, :mood_level
  end
end