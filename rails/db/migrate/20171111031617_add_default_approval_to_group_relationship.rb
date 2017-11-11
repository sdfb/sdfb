class AddDefaultApprovalToGroupRelationship < ActiveRecord::Migration

  def up
    change_column_default :group_assignments, :is_approved, false
  end

  def down
    change_column_default :group_assignments, :is_approved, nil
  end
end
