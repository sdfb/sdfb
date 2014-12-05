class UpdateAttributesRel < ActiveRecord::Migration
  def up
  	remove_column :relationships, :average_certainty
    remove_column :relationships, :is_approved
  	add_column :relationships, :max_certainty, :decimal
  	add_column :relationships, :start_date, :date
  	add_column :relationships, :end_date, :date
  	add_column :relationships, :justification, :text
  	add_column :relationships, :approved_by, :integer
  	add_column :relationships, :approved_on, :datestamp
    add_column :relationships, :edge_birthdate_certainty, :integer
  end

  def down
  end
end