class UpdateAttributesGroupAssign < ActiveRecord::Migration
  def up
  	add_column :group_assignments, :start_date, :date
  	add_column :group_assignments, :end_date, :date
  end

  def down
  end
end