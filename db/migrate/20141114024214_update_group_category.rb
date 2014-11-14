class UpdateGroupCategory < ActiveRecord::Migration
  def up
  	add_column :group_categories, :created_by, :integer
  end

  def down
  end
end
