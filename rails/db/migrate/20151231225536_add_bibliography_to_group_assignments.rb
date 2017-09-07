class AddBibliographyToGroupAssignments < ActiveRecord::Migration
  def change
    add_column :group_assignments, :bibliography, :text
  end
end
