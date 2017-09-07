class CreateGroupAssignments < ActiveRecord::Migration
  def change
    create_table :group_assignments do |t|
      t.integer :created_by
      t.integer :group_id
      t.integer :person_id
      t.integer :start_year
      t.string :start_month
      t.integer :start_day
      t.integer :end_year
      t.string :end_month
      t.integer :end_day
      t.integer :approved_by
      t.datetime :approved_on
      t.boolean :is_approved
      t.boolean :is_active, :default => true
      t.boolean :is_rejected, :default => false
      t.text :edited_by_on, :default => [].to_yaml

      t.timestamps
    end
  end
end
