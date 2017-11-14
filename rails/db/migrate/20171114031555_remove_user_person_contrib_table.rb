class RemoveUserPersonContribTable < ActiveRecord::Migration
   def up
    drop_table :user_person_contribs
  end
  def down
    create_table :user_person_contribs do |t|
      t.integer  "person_id"
      t.integer  "created_by"
      t.text     "bibliography"
      t.integer  "approved_by"
      t.date     "approved_on"
      t.boolean  "is_approved",  default: true
      t.boolean  "is_active",    default: true
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
    end
  end
end
