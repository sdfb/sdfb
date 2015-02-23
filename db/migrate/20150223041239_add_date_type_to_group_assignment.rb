class AddDateTypeToGroupAssignment < ActiveRecord::Migration
  def change
  	add_column :group_assignments, :start_date_type, :string
  	add_column :group_assignments, :end_date_type, :string
  end
end
