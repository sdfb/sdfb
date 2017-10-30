class RemoveFlagAndCommentTables < ActiveRecord::Migration
  def up
    drop_table :flags
    drop_table :comments
  end
  def down
    create_table :flags do |t|
      t.string :assoc_object_type
      t.integer :assoc_object_id
      t.text :flag_description
      t.integer :created_by
      t.integer :resolved_by
      t.datetime :resolved_at

      t.timestamps
    end
    create_table :comments do |t|
      t.string :comment_type
      t.integer :associated_contrib
      t.integer :created_by
      t.text :content

      t.timestamps
    end
  end
end
