class CreateGroupAssignments < ActiveRecord::Migration
  def change
    create_table :group_assignments do |t|
      t.integer :created_by
      t.integer :group_id
      t.integer :person_id
      t.date :start_date
      t.date :end_date
      t.integer :approved_by
      t.date :approved_on
      t.boolean :is_approved

      t.timestamps
    end
  end
end
