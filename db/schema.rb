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

ActiveRecord::Schema.define(:version => 20141114024214) do

  create_table "comments", :force => true do |t|
    t.string   "comment_type"
    t.integer  "associated_contrib"
    t.integer  "created_by"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.text     "content"
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
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "approved_by"
    t.date     "approved_on"
  end

  create_table "group_cat_assigns", :force => true do |t|
    t.integer  "group_id"
    t.integer  "group_category_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "created_by"
  end

  create_table "group_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "created_by"
  end

  create_table "groups", :force => true do |t|
    t.integer  "created_by"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "justification"
    t.string   "approved_by"
    t.string   "approved_on"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "created_by"
    t.text     "historical_significance"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.text     "rel_sum",                 :default => "'"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "search_names_all"
    t.string   "title"
    t.string   "birth_year_type"
    t.string   "ext_birth_year"
    t.string   "alt_birth_year"
    t.string   "death_year_type"
    t.string   "ext_death_year"
    t.string   "alt_death_year"
    t.text     "justification"
    t.integer  "approved_by"
    t.datetime "approved_on"
    t.integer  "odnb_id"
  end

  create_table "rel_cat_assigns", :force => true do |t|
    t.integer  "relationship_category_id"
    t.integer  "relationship_type_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "relationship_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "relationship_types", :force => true do |t|
    t.integer  "relationship_type_inverse_id"
    t.integer  "default_rel_category"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_active"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "relationships", :force => true do |t|
    t.decimal  "original_certainty"
    t.integer  "person1_index"
    t.integer  "person2_index"
    t.integer  "created_by"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.decimal  "max_certainty"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "justification"
    t.integer  "approved_by"
    t.date     "approved_on"
    t.integer  "edge_birthdate_certainty"
  end

  create_table "user_group_contribs", :force => true do |t|
    t.integer  "group_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.text     "edited_by_on",   :default => "'--- []\n'"
    t.text     "reviewed_by_on", :default => "'--- []\n'"
  end

  create_table "user_person_contribs", :force => true do |t|
    t.integer  "person_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.text     "edited_by_on",   :default => "'--- []\n'"
    t.text     "reviewed_by_on", :default => "'--- []\n'"
  end

  create_table "user_rel_contribs", :force => true do |t|
    t.integer  "relationship_id"
    t.integer  "created_by"
    t.string   "confidence_type"
    t.text     "annotation"
    t.text     "bibliography"
    t.string   "relationship_type"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.text     "edited_by_on",      :default => "'--- []\n'"
    t.text     "reviewed_by_on",    :default => "'--- []\n'"
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
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "prefix"
    t.string   "orcid"
    t.integer  "created_by"
    t.boolean  "is_curator",            :default => false
    t.boolean  "curator_revoked",       :default => false
    t.string   "username"
  end

end
