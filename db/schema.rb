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

ActiveRecord::Schema[8.1].define(version: 2026_09_16_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "case_assignments", force: :cascade do |t|
    t.bigint "case_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["case_id", "user_id"], name: "index_case_assignments_on_case_id_and_user_id", unique: true
    t.index ["case_id"], name: "index_case_assignments_on_case_id"
    t.index ["user_id"], name: "index_case_assignments_on_user_id"
  end

  create_table "cases", force: :cascade do |t|
    t.datetime "closed_at"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "opened_at", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_cases_on_code", unique: true
  end

  create_table "custody_movements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "evidence_id", null: false
    t.bigint "from_user_id"
    t.text "notes"
    t.bigint "performed_by_id", null: false
    t.string "reason", null: false
    t.bigint "to_user_id", null: false
    t.datetime "transferred_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evidence_id", "transferred_at"], name: "index_custody_movements_on_evidence_id_and_transferred_at"
    t.index ["evidence_id"], name: "index_custody_movements_on_evidence_id"
    t.index ["from_user_id"], name: "index_custody_movements_on_from_user_id"
    t.index ["performed_by_id"], name: "index_custody_movements_on_performed_by_id"
    t.index ["to_user_id"], name: "index_custody_movements_on_to_user_id"
  end

  create_table "evidence_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_evidence_types_on_name", unique: true
  end

  create_table "evidences", force: :cascade do |t|
    t.bigint "case_id", null: false
    t.string "code", null: false
    t.datetime "collected_at", null: false
    t.datetime "created_at", null: false
    t.bigint "current_custodian_id", null: false
    t.text "description"
    t.bigint "evidence_type_id", null: false
    t.string "location"
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_evidences_on_case_id"
    t.index ["code"], name: "index_evidences_on_code", unique: true
    t.index ["current_custodian_id"], name: "index_evidences_on_current_custodian_id"
    t.index ["evidence_type_id"], name: "index_evidences_on_evidence_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "case_assignments", "cases"
  add_foreign_key "case_assignments", "users"
  add_foreign_key "custody_movements", "evidences"
  add_foreign_key "custody_movements", "users", column: "from_user_id"
  add_foreign_key "custody_movements", "users", column: "performed_by_id"
  add_foreign_key "custody_movements", "users", column: "to_user_id"
  add_foreign_key "evidences", "cases"
  add_foreign_key "evidences", "evidence_types"
  add_foreign_key "evidences", "users", column: "current_custodian_id"
end
