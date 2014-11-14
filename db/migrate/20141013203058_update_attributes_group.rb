class UpdateAttributesGroup < ActiveRecord::Migration
  def up
	add_column :groups, :justification, :text
	add_column :groups, :approved_by, :string
	add_column :groups, :approved_on, :string
  end

  def down
  end
end