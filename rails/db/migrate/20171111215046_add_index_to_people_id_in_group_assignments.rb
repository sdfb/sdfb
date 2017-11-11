class AddIndexToPeopleIdInGroupAssignments < ActiveRecord::Migration
  def change
    add_index :group_assignments, :group_id
    add_index :group_assignments, :person_id
  end
end
