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

ActiveRecord::Schema[8.1].define(version: 2026_05_07_133501) do
  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "status"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "email_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "email_template_id", null: false
    t.text "error_message"
    t.datetime "sent_at"
    t.integer "status"
    t.integer "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_template_id"], name: "index_email_logs_on_email_template_id"
    t.index ["student_id"], name: "index_email_logs_on_student_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.text "body"
    t.integer "category"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "progresses", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "lesson_id", null: false
    t.integer "status"
    t.integer "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_progresses_on_lesson_id"
    t.index ["student_id"], name: "index_progresses_on_student_id"
  end

  create_table "student_course_enrollments", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.date "enrolled_on"
    t.integer "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_student_course_enrollments_on_course_id"
    t.index ["student_id"], name: "index_student_course_enrollments_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "address_detail"
    t.string "affiliated_association"
    t.date "application_date"
    t.string "application_method"
    t.string "application_qualification"
    t.string "attendance"
    t.string "category"
    t.string "city"
    t.text "comment"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "fax"
    t.string "fax_type"
    t.string "furigana"
    t.string "gender"
    t.string "jfa_id"
    t.string "name"
    t.date "pass_processed_date"
    t.integer "payment_amount"
    t.date "payment_completed_date"
    t.date "payment_due_date"
    t.string "payment_method"
    t.string "payment_status"
    t.string "phone_home"
    t.string "phone_mobile"
    t.string "phone_work"
    t.string "postal_code"
    t.string "prefecture"
    t.date "promotion_processed_date"
    t.string "reception_number"
    t.string "referee_number"
    t.string "result"
    t.string "seminar_number"
    t.string "skill_category"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_students_on_email", unique: true
  end

  add_foreign_key "email_logs", "email_templates"
  add_foreign_key "email_logs", "students"
  add_foreign_key "lessons", "courses"
  add_foreign_key "progresses", "lessons"
  add_foreign_key "progresses", "students"
  add_foreign_key "student_course_enrollments", "courses"
  add_foreign_key "student_course_enrollments", "students"
end
