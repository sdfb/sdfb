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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150428042348) do

  create_table "comments", :force => true do |t|
    t.string   "comment_type"
    t.integer  "associated_contrib"
    t.integer  "created_by"
    t.text     "content"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "flags", :force => true do |t|
    t.string   "assoc_object_type"
    t.integer  "assoc_object_id"
    t.text     "flag_description"
    t.integer  "created_by"
    t.integer  "resolved_by"
    t.datetime "resolved_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "group_assignments", :force => true do |t|
    t.integer  "created_by"
    t.integer  "group_id"
    t.integer  "person_id"
    t.integer  "start_year"
    t.string   "start_month"
    t.integer  "start_day"
    t.integer  "end_year"
    t.string   "end_month"
    t.integer  "end_day"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved"
    t.boolean  "is_active",           :default => true
    t.boolean  "is_rejected",         :default => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "person_autocomplete"
    t.string   "start_date_type"
    t.string   "end_date_type"
    t.text     "last_edit",           :default => "--- []\n"
  end

  create_table "group_cat_assigns", :force => true do |t|
    t.integer  "group_id"
    t.integer  "group_category_id"
    t.integer  "created_by"
    t.string   "approved_by"
    t.string   "approved_on"
    t.boolean  "is_approved",       :default => false
    t.boolean  "is_active",         :default => true
    t.boolean  "is_rejected",       :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.text     "last_edit",         :default => "--- []\n"
  end

  create_table "group_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "created_by"
    t.string   "approved_by"
    t.string   "approved_on"
    t.boolean  "is_approved", :default => false
    t.boolean  "is_active",   :default => true
    t.boolean  "is_rejected", :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "last_edit",   :default => "--- []\n"
  end

  create_table "groups", :force => true do |t|
    t.integer  "created_by"
    t.string   "name"
    t.text     "description"
    t.text     "justification"
    t.integer  "start_year"
    t.integer  "end_year"
    t.string   "approved_by"
    t.string   "approved_on"
    t.boolean  "is_approved",     :default => false
    t.text     "person_list",     :default => "--- []\n"
    t.boolean  "is_active",       :default => true
    t.boolean  "is_rejected",     :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "start_date_type"
    t.string   "end_date_type"
    t.text     "last_edit",       :default => "--- []\n"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "created_by"
    t.text     "historical_significance"
    t.text     "rel_sum",                 :default => "--- []\n"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "title"
    t.string   "birth_year_type"
    t.string   "ext_birth_year"
    t.string   "alt_birth_year"
    t.string   "death_year_type"
    t.string   "ext_death_year"
    t.string   "alt_death_year"
    t.string   "gender"
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "odnb_id"
    t.boolean  "is_approved",             :default => false
    t.text     "group_list",              :default => "--- []\n"
    t.boolean  "is_active",               :default => true
    t.boolean  "is_rejected",             :default => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "display_name"
    t.text     "search_names_all"
    t.text     "last_edit",               :default => "--- []\n"
  end

  create_table "rel_cat_assigns", :force => true do |t|
    t.integer  "relationship_category_id"
    t.integer  "relationship_type_id"
    t.integer  "created_by"
    t.string   "approved_by"
    t.string   "approved_on"
    t.boolean  "is_approved",              :default => false
    t.boolean  "is_active",                :default => true
    t.boolean  "is_rejected",              :default => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.text     "last_edit",                :default => "--- []\n"
  end

  create_table "relationship_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "is_approved", :default => false
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "created_by"
    t.boolean  "is_active",   :default => true
    t.boolean  "is_rejected", :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.text     "last_edit",   :default => "--- []\n"
  end

  create_table "relationship_types", :force => true do |t|
    t.integer  "relationship_type_inverse"
    t.integer  "default_rel_category"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_active",                 :default => true
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",               :default => false
    t.integer  "created_by"
    t.boolean  "is_rejected",               :default => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.text     "last_edit",                 :default => "--- []\n"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "original_certainty"
    t.integer  "person1_index"
    t.integer  "person2_index"
    t.integer  "created_by"
    t.integer  "max_certainty"
    t.integer  "start_year"
    t.string   "start_month"
    t.integer  "start_day"
    t.integer  "end_year"
    t.string   "end_month"
    t.integer  "end_day"
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.text     "types_list",               :default => "--- []\n"
    t.integer  "edge_birthdate_certainty"
    t.boolean  "is_approved",              :default => false
    t.boolean  "is_active",                :default => true
    t.boolean  "is_rejected",              :default => false
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "person1_autocomplete"
    t.string   "person2_autocomplete"
    t.string   "start_date_type"
    t.string   "end_date_type"
    t.text     "type_certainty_list",      :default => "--- []\n"
    t.integer  "max_user_rel_edit"
    t.text     "last_edit",                :default => "--- []\n"
  end

  create_table "user_group_contribs", :force => true do |t|
    t.integer  "group_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.boolean  "is_approved",  :default => true
    t.boolean  "is_active",    :default => true
    t.boolean  "is_rejected",  :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.text     "last_edit",    :default => "--- []\n"
  end

  create_table "user_person_contribs", :force => true do |t|
    t.integer  "person_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.integer  "approved_by"
    t.date     "approved_on"
    t.boolean  "is_approved",         :default => true
    t.boolean  "is_active",           :default => true
    t.boolean  "is_rejected",         :default => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "person_autocomplete"
    t.text     "last_edit",           :default => "--- []\n"
  end

  create_table "user_rel_contribs", :force => true do |t|
    t.integer  "relationship_id"
    t.integer  "created_by"
    t.integer  "certainty"
    t.text     "annotation"
    t.text     "bibliography"
    t.integer  "relationship_type_id"
    t.integer  "start_year"
    t.string   "start_month"
    t.integer  "start_day"
    t.integer  "end_year"
    t.string   "end_month"
    t.integer  "end_day"
    t.integer  "approved_by"
    t.date     "approved_on"
    t.boolean  "is_approved",          :default => true
    t.boolean  "is_active",            :default => true
    t.boolean  "is_rejected",          :default => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "person1_autocomplete"
    t.string   "person2_autocomplete"
    t.string   "person1_selection"
    t.string   "person2_selection"
    t.string   "start_date_type"
    t.string   "end_date_type"
    t.text     "last_edit",            :default => "--- []\n"
  end

  create_table "users", :force => true do |t|
    t.text     "about_description"
    t.string   "affiliation"
    t.string   "email"
    t.string   "first_name"
    t.boolean  "is_active"
    t.string   "last_name"
    t.string   "password"
    t.string   "password_confirmation"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "user_type"
    t.string   "prefix"
    t.string   "orcid"
    t.integer  "created_by"
    t.boolean  "is_curator",            :default => false
    t.boolean  "curator_revoked",       :default => false
    t.string   "username"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

end
