class CreateMoodTriggers < ActiveRecord::Migration[8.0]
  def change
    create_table :mood_triggers, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :mood_entry_id, limit: 36, null: false
      t.string :trigger_id, limit: 36, null: false

      t.timestamps
    end

    add_foreign_key :mood_triggers, :mood_entries, column: :mood_entry_id
    add_foreign_key :mood_triggers, :triggers, column: :trigger_id
    add_index :mood_triggers, :mood_entry_id
    add_index :mood_triggers, :trigger_id
    add_index :mood_triggers, [:mood_entry_id, :trigger_id], unique: true, name: 'index_mood_triggers_unique'
  end
end