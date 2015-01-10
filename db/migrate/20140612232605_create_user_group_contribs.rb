class CreateUserGroupContribs < ActiveRecord::Migration
  def change
    create_table :user_group_contribs do |t|
      t.integer :group_id
      t.integer :created_by
      t.text :annotation
      t.text :bibliography
      t.integer :approved_by
      t.datetime :approved_on
      t.boolean :is_approved, :default => true
      t.boolean :is_active, :default => true
      t.boolean :is_rejected, :defailt => false
      t.text :edited_by_on, :default => [].to_yaml

      t.timestamps
    end
  end
end
