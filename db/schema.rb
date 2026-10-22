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

ActiveRecord::Schema[8.2].define(version: 2026_10_22_120000) do
  create_table "lesson_completions", force: :cascade do |t|
    t.integer "student_id", null: false
    t.string "lesson_slug", null: false
    t.datetime "completed_at", null: false
    t.string "source", null: false
    t.string "model"
    t.json "evidence"
    t.index ["student_id", "lesson_slug"], name: "index_lesson_completions_on_student_id_and_lesson_slug", unique: true
    t.index ["student_id"], name: "index_lesson_completions_on_student_id"
  end

  create_table "pending_enrollments", force: :cascade do |t|
    t.string "code_digest", null: false
    t.string "status", default: "pending", null: false
    t.datetime "expires_at", null: false
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_digest"], name: "index_pending_enrollments_on_code_digest", unique: true
    t.index ["student_id"], name: "index_pending_enrollments_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "public_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_students_on_public_id", unique: true
  end

  add_foreign_key "lesson_completions", "students"
  add_foreign_key "pending_enrollments", "students"
end
