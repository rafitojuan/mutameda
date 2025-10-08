# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_01_000007) do
  create_table "mood_entries", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.integer "mood_level", null: false
    t.integer "energy_level"
    t.integer "sleep_quality"
    t.integer "anxiety_level"
    t.integer "stress_level"
    t.text "notes"
    t.datetime "logged_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["logged_at"], name: "index_mood_entries_on_logged_at"
    t.index ["mood_level"], name: "index_mood_entries_on_mood_level"
    t.index ["user_id"], name: "index_mood_entries_on_user_id"
  end

  create_table "mood_triggers", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "mood_entry_id", limit: 36, null: false
    t.string "trigger_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mood_entry_id", "trigger_id"], name: "index_mood_triggers_unique", unique: true
    t.index ["mood_entry_id"], name: "index_mood_triggers_on_mood_entry_id"
    t.index ["trigger_id"], name: "index_mood_triggers_on_trigger_id"
  end

  create_table "resource_interactions", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "resource_id", limit: 36, null: false
    t.string "interaction_type", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interaction_type"], name: "index_resource_interactions_on_interaction_type"
    t.index ["resource_id"], name: "index_resource_interactions_on_resource_id"
    t.index ["user_id"], name: "index_resource_interactions_on_user_id"
  end

  create_table "resources", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "content"
    t.string "category", limit: 50, null: false
    t.string "resource_type", limit: 50, null: false
    t.string "external_url", limit: 500
    t.boolean "is_published", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_resources_on_category"
    t.index ["is_published"], name: "index_resources_on_is_published"
    t.index ["resource_type"], name: "index_resources_on_resource_type"
  end

  create_table "triggers", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "category", limit: 50, null: false
    t.string "color_code", limit: 7, default: "#6c757d"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_triggers_on_category"
    t.index ["is_active"], name: "index_triggers_on_is_active"
  end

  create_table "user_settings", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.string "setting_key", limit: 100, null: false
    t.text "setting_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "setting_key"], name: "index_user_settings_unique", unique: true
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", id: { type: :string, limit: 36 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "mood_entries", "users"
  add_foreign_key "mood_triggers", "mood_entries"
  add_foreign_key "mood_triggers", "triggers"
  add_foreign_key "resource_interactions", "resources"
  add_foreign_key "resource_interactions", "users"
  add_foreign_key "user_settings", "users"
end
