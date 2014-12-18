class CreateUserGroupContribs < ActiveRecord::Migration
  def change
    create_table :user_group_contribs do |t|
      t.integer :group_id
      t.integer :created_by
      t.text :annotation
      t.text :bibliography
      t.text :edited_by_on, :default => [].to_yaml
      t.text :reviewed_by_on, :default => [].to_yaml

      t.timestamps
    end
  end
end
