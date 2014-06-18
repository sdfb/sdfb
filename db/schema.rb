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

ActiveRecord::Schema.define(:version => 20140615185123) do

  create_table "group_assignments", :force => true do |t|
    t.integer  "created_by"
    t.integer  "group_id"
    t.integer  "person_id"
    t.boolean  "is_approved"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "groups", :force => true do |t|
    t.integer  "created_by"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_approved"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "people", :force => true do |t|
    t.integer  "original_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "created_by"
    t.integer  "birth_year"
    t.integer  "death_year"
    t.text     "historical_significance"
    t.boolean  "is_approved"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "relationships", :force => true do |t|
    t.decimal  "average_certainty"
    t.boolean  "is_approved"
    t.decimal  "original_certainty"
    t.integer  "person1_index"
    t.integer  "person2_index"
    t.integer  "created_by"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "user_group_contribs", :force => true do |t|
    t.integer  "group_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.boolean  "is_flagged"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "user_person_contribs", :force => true do |t|
    t.integer  "person_id"
    t.integer  "created_by"
    t.text     "annotation"
    t.text     "bibliography"
    t.boolean  "is_flagged"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "user_rel_contribs", :force => true do |t|
    t.integer  "relationship_id"
    t.integer  "created_by"
    t.string   "confidence_type"
    t.text     "annotation"
    t.text     "bibliography"
    t.string   "relationship_type"
    t.boolean  "is_flagged"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
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
    t.boolean  "is_admin"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

end
