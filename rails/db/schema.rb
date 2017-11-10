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

ActiveRecord::Schema.define(version: 20171110154911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "group_assignments", force: :cascade do |t|
    t.integer  "created_by"
    t.integer  "group_id"
    t.integer  "person_id"
    t.integer  "start_year"
    t.string   "start_month",     limit: 255
    t.integer  "start_day"
    t.integer  "end_year"
    t.string   "end_month",       limit: 255
    t.integer  "end_day"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved"
    t.boolean  "is_active",                   default: true
    t.boolean  "is_rejected",                 default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "start_date_type", limit: 255
    t.string   "end_date_type",   limit: 255
    t.text     "annotation"
    t.text     "bibliography"
  end

  create_table "group_cat_assigns", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "group_category_id"
    t.integer  "created_by"
    t.string   "approved_by",       limit: 255
    t.string   "approved_on",       limit: 255
    t.boolean  "is_approved",                   default: false
    t.boolean  "is_active",                     default: true
    t.boolean  "is_rejected",                   default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "annotation"
    t.text     "bibliography"
  end

  create_table "group_categories", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description"
    t.integer  "created_by"
    t.string   "approved_by",  limit: 255
    t.string   "approved_on",  limit: 255
    t.boolean  "is_approved",              default: false
    t.boolean  "is_active",                default: true
    t.boolean  "is_rejected",              default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "annotation"
    t.text     "bibliography"
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "created_by"
    t.string   "name",            limit: 255
    t.text     "description"
    t.text     "justification"
    t.integer  "start_year"
    t.integer  "end_year"
    t.string   "approved_by",     limit: 255
    t.string   "approved_on",     limit: 255
    t.boolean  "is_approved",                 default: false
    t.text     "person_list",                 default: "--- []\n"
    t.boolean  "is_active",                   default: true
    t.boolean  "is_rejected",                 default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "start_date_type", limit: 255
    t.string   "end_date_type",   limit: 255
    t.text     "bibliography"
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name",              limit: 255
    t.string   "last_name",               limit: 255
    t.integer  "created_by"
    t.text     "historical_significance"
    t.text     "rel_sum",                             default: "--- []\n"
    t.string   "prefix",                  limit: 255
    t.string   "suffix",                  limit: 255
    t.string   "title",                   limit: 255
    t.string   "birth_year_type",         limit: 255
    t.string   "ext_birth_year",          limit: 255
    t.string   "alt_birth_year",          limit: 255
    t.string   "death_year_type",         limit: 255
    t.string   "ext_death_year",          limit: 255
    t.string   "alt_death_year",          limit: 255
    t.string   "gender",                  limit: 255
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "odnb_id"
    t.boolean  "is_approved",                         default: false
    t.text     "group_list",                          default: "--- []\n"
    t.boolean  "is_active",                           default: true
    t.boolean  "is_rejected",                         default: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "display_name",            limit: 255
    t.text     "search_names_all"
    t.text     "bibliography"
    t.text     "aliases"
  end

  create_table "rel_cat_assigns", force: :cascade do |t|
    t.integer  "relationship_category_id"
    t.integer  "relationship_type_id"
    t.integer  "created_by"
    t.string   "approved_by",              limit: 255
    t.string   "approved_on",              limit: 255
    t.boolean  "is_approved",                          default: false
    t.boolean  "is_active",                            default: true
    t.boolean  "is_rejected",                          default: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.text     "annotation"
    t.text     "bibliography"
  end

  create_table "relationship_categories", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description"
    t.boolean  "is_approved",              default: false
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "created_by"
    t.boolean  "is_active",                default: true
    t.boolean  "is_rejected",              default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "annotation"
    t.text     "bibliography"
  end

  create_table "relationship_types", force: :cascade do |t|
    t.integer  "relationship_type_inverse"
    t.integer  "default_rel_category"
    t.string   "name",                      limit: 255
    t.text     "description"
    t.boolean  "is_active",                             default: true
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",                           default: false
    t.integer  "created_by"
    t.boolean  "is_rejected",                           default: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.text     "annotation"
    t.text     "bibliography"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "original_certainty"
    t.integer  "person1_index"
    t.integer  "person2_index"
    t.integer  "created_by"
    t.integer  "max_certainty"
    t.integer  "start_year"
    t.string   "start_month",              limit: 255
    t.integer  "start_day"
    t.integer  "end_year"
    t.string   "end_month",                limit: 255
    t.integer  "end_day"
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.text     "types_list",                           default: "--- []\n"
    t.integer  "edge_birthdate_certainty"
    t.boolean  "is_approved",                          default: false
    t.boolean  "is_active",                            default: true
    t.boolean  "is_rejected",                          default: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "start_date_type",          limit: 255
    t.string   "end_date_type",            limit: 255
    t.text     "type_certainty_list",                  default: "--- []\n"
    t.text     "bibliography"
  end

  add_index "relationships", ["person1_index"], name: "index_relationships_on_person1_index", using: :btree
  add_index "relationships", ["person2_index"], name: "index_relationships_on_person2_index", using: :btree

  create_table "user_group_contribs", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",  default: true
    t.boolean  "is_active",    default: true
    t.boolean  "is_rejected",  default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "user_person_contribs", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.integer  "approved_by"
    t.date     "approved_on"
    t.boolean  "is_approved",  default: true
    t.boolean  "is_active",    default: true
    t.boolean  "is_rejected",  default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "user_rel_contribs", force: :cascade do |t|
    t.integer  "relationship_id"
    t.integer  "created_by"
    t.integer  "certainty"
    t.text     "annotation"
    t.text     "bibliography"
    t.integer  "relationship_type_id"
    t.integer  "start_year"
    t.string   "start_month",          limit: 255
    t.integer  "start_day"
    t.integer  "end_year"
    t.string   "end_month",            limit: 255
    t.integer  "end_day"
    t.integer  "approved_by"
    t.date     "approved_on"
    t.boolean  "is_approved",                      default: true
    t.boolean  "is_active",                        default: true
    t.boolean  "is_rejected",                      default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "start_date_type",      limit: 255
    t.string   "end_date_type",        limit: 255
    t.boolean  "is_locked",                        default: false
  end

  add_index "user_rel_contribs", ["relationship_id"], name: "index_user_rel_contribs_on_relationship_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "about_description"
    t.string   "affiliation",            limit: 255
    t.string   "email",                  limit: 255
    t.string   "first_name",             limit: 255
    t.boolean  "is_active",                          default: true
    t.string   "last_name",              limit: 255
    t.string   "user_type",                          default: "Standard"
    t.string   "prefix",                 limit: 255
    t.string   "orcid",                  limit: 255
    t.integer  "created_by"
    t.string   "username",               limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "auth_token",             limit: 255
    t.string   "password_digest",        limit: 255
    t.string   "password_reset_sent_at", limit: 255
    t.string   "password_reset_token",   limit: 255
    t.boolean  "is_public",                          default: false
  end

end
