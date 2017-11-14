class RemoveGroupCatAssigneTable < ActiveRecord::Migration
   def up
    drop_table :group_cat_assigns
  end
  def down
    create_table :group_cat_assigns do |t|
      t.integer  "group_id"
      t.integer  "group_category_id"
      t.integer  "created_by"
      t.string   "approved_by",       limit: 255
      t.string   "approved_on",       limit: 255
      t.boolean  "is_approved",                   default: false
      t.boolean  "is_active",                     default: true
      t.datetime "created_at",                                    null: false
      t.datetime "updated_at",                                    null: false
      t.text     "bibliography"
    end
  end
end
