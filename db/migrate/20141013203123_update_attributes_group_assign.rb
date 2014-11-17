class UpdateAttributesGroupAssign < ActiveRecord::Migration
  def up
  	remove_column :group_assignments, :is_approved
  	add_column :group_assignments, :start_date, :date
  	add_column :group_assignments, :end_date, :date
  	add_column :group_assignments, :approved_by, :integer
  	add_column :group_assignments, :approved_on, :date
  end

  def down
  end
end