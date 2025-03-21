# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170825034823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "department_divisions", force: :cascade do |t|
    t.integer  "department_id"
    t.string   "division"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "department_divisions", ["department_id"], name: "index_department_divisions_on_department_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "abbrev"
  end

  create_table "endorsement_pos", force: :cascade do |t|
    t.string   "control_number"
    t.string   "recipient"
    t.string   "recipient_designation"
    t.string   "thru"
    t.string   "thru_designation"
    t.string   "sender"
    t.string   "sender_designation"
    t.string   "cc"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "user_id"
  end

  add_index "endorsement_pos", ["user_id"], name: "index_endorsement_pos_on_user_id", using: :btree

  create_table "endorsements", force: :cascade do |t|
    t.string   "control_number"
    t.string   "recipient"
    t.string   "recipient_designation"
    t.string   "thru"
    t.string   "thru_designation"
    t.string   "sender"
    t.string   "sender_designation"
    t.string   "cc"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "user_id"
  end

  add_index "endorsements", ["user_id"], name: "index_endorsements_on_user_id", using: :btree

  create_table "inspectors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "inspectors", ["name"], name: "index_inspectors_on_name", using: :btree

  create_table "item_masterlists", force: :cascade do |t|
    t.string   "item_code"
    t.string   "name"
    t.string   "name_parameterize"
    t.integer  "unit_id"
    t.integer  "supply_id"
    t.decimal  "cost",              precision: 10, scale: 2, default: 0.0
    t.boolean  "stock",                                      default: true
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.text     "photo_data"
    t.string   "filename"
    t.integer  "on_hand_count"
  end

  add_index "item_masterlists", ["name"], name: "index_item_masterlists_on_name", using: :btree
  add_index "item_masterlists", ["name_parameterize"], name: "index_item_masterlists_on_name_parameterize", using: :btree
  add_index "item_masterlists", ["supply_id"], name: "index_item_masterlists_on_supply_id", using: :btree
  add_index "item_masterlists", ["unit_id"], name: "index_item_masterlists_on_unit_id", using: :btree

  create_table "mode_of_procurements", force: :cascade do |t|
    t.string   "mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "procurement_forms", force: :cascade do |t|
    t.string   "long_name"
    t.string   "short_name"
    t.string   "effect"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_in_charges", force: :cascade do |t|
    t.string   "name"
    t.string   "designation"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "project_in_charges", ["name"], name: "index_project_in_charges_on_name", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "project_in_charge_id"
    t.string   "pr_number"
    t.string   "pow_number"
    t.string   "prs_number",           default: ""
    t.string   "cert_number",          default: ""
    t.string   "purpose"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "endorsement_id"
  end

  add_index "projects", ["cert_number"], name: "index_projects_on_cert_number", using: :btree
  add_index "projects", ["department_id"], name: "index_projects_on_department_id", using: :btree
  add_index "projects", ["endorsement_id"], name: "index_projects_on_endorsement_id", using: :btree
  add_index "projects", ["pow_number"], name: "index_projects_on_pow_number", using: :btree
  add_index "projects", ["pr_number"], name: "index_projects_on_pr_number", using: :btree
  add_index "projects", ["project_in_charge_id"], name: "index_projects_on_project_in_charge_id", using: :btree
  add_index "projects", ["prs_number"], name: "index_projects_on_prs_number", using: :btree
  add_index "projects", ["purpose"], name: "index_projects_on_purpose", using: :btree

  create_table "purchase_orders", force: :cascade do |t|
    t.string   "po_number",              null: false
    t.date     "date_issued"
    t.integer  "project_id"
    t.integer  "supplier_id"
    t.integer  "mode_of_procurement_id"
    t.string   "iar_number"
    t.integer  "inspector_id"
    t.date     "date_of_delivery"
    t.boolean  "complete"
    t.text     "remarks"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "endorsement_po_id"
  end

  add_index "purchase_orders", ["endorsement_po_id"], name: "index_purchase_orders_on_endorsement_po_id", using: :btree
  add_index "purchase_orders", ["iar_number"], name: "index_purchase_orders_on_iar_number", using: :btree
  add_index "purchase_orders", ["inspector_id"], name: "index_purchase_orders_on_inspector_id", using: :btree
  add_index "purchase_orders", ["mode_of_procurement_id"], name: "index_purchase_orders_on_mode_of_procurement_id", using: :btree
  add_index "purchase_orders", ["po_number"], name: "index_purchase_orders_on_po_number", using: :btree
  add_index "purchase_orders", ["project_id"], name: "index_purchase_orders_on_project_id", using: :btree
  add_index "purchase_orders", ["supplier_id"], name: "index_purchase_orders_on_supplier_id", using: :btree

  create_table "req_issued_slips", force: :cascade do |t|
    t.string   "ris_number",                      null: false
    t.boolean  "savings",         default: false
    t.date     "date_issued"
    t.integer  "project_id"
    t.integer  "warehouseman_id"
    t.date     "date_released"
    t.string   "approved_by"
    t.string   "issued_by"
    t.string   "withdrawn_by",    default: ""
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "req_issued_slips", ["approved_by"], name: "index_req_issued_slips_on_approved_by", using: :btree
  add_index "req_issued_slips", ["issued_by"], name: "index_req_issued_slips_on_issued_by", using: :btree
  add_index "req_issued_slips", ["project_id"], name: "index_req_issued_slips_on_project_id", using: :btree
  add_index "req_issued_slips", ["ris_number"], name: "index_req_issued_slips_on_ris_number", using: :btree
  add_index "req_issued_slips", ["savings"], name: "index_req_issued_slips_on_savings", using: :btree
  add_index "req_issued_slips", ["warehouseman_id"], name: "index_req_issued_slips_on_warehouseman_id", using: :btree
  add_index "req_issued_slips", ["withdrawn_by"], name: "index_req_issued_slips_on_withdrawn_by", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.integer  "source_stock_id"
    t.integer  "purchase_order_id"
    t.boolean  "savings",                                     default: false
    t.integer  "req_issued_slip_id"
    t.integer  "project_id"
    t.integer  "item_number"
    t.integer  "item_id"
    t.decimal  "cost",               precision: 10, scale: 2
    t.decimal  "stock_in",           precision: 8,  scale: 2, default: 0.0
    t.decimal  "stock_out",          precision: 8,  scale: 2, default: 0.0
    t.decimal  "prs_quantity",       precision: 8,  scale: 2
    t.decimal  "stock_bal",          precision: 8,  scale: 2, default: 0.0
    t.string   "remarks"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
  end

  add_index "stocks", ["item_id"], name: "index_stocks_on_item_id", using: :btree
  add_index "stocks", ["project_id"], name: "index_stocks_on_project_id", using: :btree
  add_index "stocks", ["purchase_order_id"], name: "index_stocks_on_purchase_order_id", using: :btree
  add_index "stocks", ["req_issued_slip_id"], name: "index_stocks_on_req_issued_slip_id", using: :btree
  add_index "stocks", ["savings"], name: "index_stocks_on_savings", using: :btree
  add_index "stocks", ["source_stock_id"], name: "index_stocks_on_source_stock_id", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "suppliers", ["name"], name: "index_suppliers_on_name", using: :btree

  create_table "supplies", force: :cascade do |t|
    t.string   "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "supplies", ["kind"], name: "index_supplies_on_kind", using: :btree

  create_table "system_roles", force: :cascade do |t|
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_actions_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "purchase_order_id"
    t.integer  "req_issued_slip_id"
    t.text     "action"
    t.string   "genkey"
    t.boolean  "assigned",           default: false
    t.integer  "admin_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "user_actions_logs", ["admin_id"], name: "index_user_actions_logs_on_admin_id", using: :btree
  add_index "user_actions_logs", ["assigned"], name: "index_user_actions_logs_on_assigned", using: :btree
  add_index "user_actions_logs", ["purchase_order_id"], name: "index_user_actions_logs_on_purchase_order_id", using: :btree
  add_index "user_actions_logs", ["req_issued_slip_id"], name: "index_user_actions_logs_on_req_issued_slip_id", using: :btree
  add_index "user_actions_logs", ["user_id"], name: "index_user_actions_logs_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "designation"
    t.integer  "department_id"
    t.integer  "department_division_id"
    t.string   "username"
    t.integer  "system_role_id"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["department_division_id"], name: "index_users_on_department_division_id", using: :btree
  add_index "users", ["department_id"], name: "index_users_on_department_id", using: :btree
  add_index "users", ["system_role_id"], name: "index_users_on_system_role_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "warehousemen", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "warehousemen", ["name"], name: "index_warehousemen_on_name", using: :btree

end
