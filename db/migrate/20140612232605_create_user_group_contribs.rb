class CreateUserGroupContribs < ActiveRecord::Migration
  def change
    create_table :user_group_contribs do |t|
      t.integer :group_id
      t.integer :created_by
      t.text :annotation
      t.text :bibliography
      t.integer :approved_by
      t.datetime :approved_on
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
