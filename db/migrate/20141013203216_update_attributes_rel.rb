class UpdateAttributesRel < ActiveRecord::Migration
  def up
  	remove_column :relationships, :average_certainty
  	add_column :relationships, :max_certainty, :decimal
  	add_column :relationships, :start_date, :date
  	add_column :relationships, :end_date, :date
  	add_column :relationships, :justification, :text
  	add_column :relationships, :approved_by, :integer
  	add_column :relationships, :approved_on, :datestamp
  end

  def down
  end
end