class RemoveUserGroupContribTable < ActiveRecord::Migration
   def up
    drop_table :user_group_contribs
  end
  def down
    create_table :user_group_contribs do |t|
      t.integer  "group_id"
      t.integer  "created_by"
      t.text     "bibliography"
      t.integer  "approved_by"
      t.datetime "approved_on"
      t.boolean  "is_approved",  default: true
      t.boolean  "is_active",    default: true
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
    end
  end
end
