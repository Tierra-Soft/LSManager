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

ActiveRecord::Schema[8.1].define(version: 2026_05_08_082219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.text "raw_message"
    t.datetime "scheduled_at"
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
    t.integer "total_score", default: 100, null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "progresses", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "lesson_id", null: false
    t.integer "score", default: 0, null: false
    t.integer "status"
    t.integer "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_progresses_on_lesson_id"
    t.index ["student_id"], name: "index_progresses_on_student_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
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
    t.boolean "active", default: true, null: false
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
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "student_course_enrollments", "courses"
  add_foreign_key "student_course_enrollments", "students"
end
