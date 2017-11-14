class RemoveGroupCategoryTable < ActiveRecord::Migration
   def up
    drop_table :group_categories
  end
  def down
    create_table :group_categories do |t|
      t.string   "name",         limit: 255
      t.text     "description"
      t.integer  "created_by"
      t.string   "approved_by",  limit: 255
      t.string   "approved_on",  limit: 255
      t.boolean  "is_approved",              default: false
      t.boolean  "is_active",                default: true
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
      t.text     "bibliography"
    end
  end
end
