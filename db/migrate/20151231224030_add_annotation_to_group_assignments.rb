class AddAnnotationToGroupAssignments < ActiveRecord::Migration
  def change
    add_column :group_assignments, :annotation, :text
  end
end
