class CreateGroupAssignments < ActiveRecord::Migration
  def change
    create_table :group_assignments do |t|
      t.integer :created_by
      t.integer :group_id
      t.integer :person_id
      t.boolean :is_approved

      t.timestamps
    end
  end
end
