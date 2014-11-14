class UpdateGroupCatAssignments < ActiveRecord::Migration
  def up
  	add_column :group_cat_assigns, :created_by, :integer
  end

  def down
  end
end
