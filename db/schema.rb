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

ActiveRecord::Schema[8.0].define(version: 2025_11_12_235105) do
  create_table "code_examples", force: :cascade do |t|
    t.string "title", null: false
    t.text "code"
    t.integer "user_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_page_id"], name: "index_code_examples_on_user_page_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.string "title", null: false
    t.text "prompt"
    t.text "starter_code"
    t.integer "user_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_page_id"], name: "index_exercises_on_user_page_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "extension"
    t.string "command"
    t.index ["name"], name: "index_languages_on_name", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.string "title", null: false
    t.text "content"
    t.integer "user_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_page_id"], name: "index_sections_on_user_page_id"
  end

  create_table "tutorials", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_pages", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.text "description"
    t.text "content"
    t.integer "downloads"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "accent_color"
    t.integer "language_id"
    t.index ["language_id"], name: "index_user_pages_on_language_id"
  end
end
