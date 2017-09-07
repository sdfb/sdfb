class AddDateTypeToRelationships < ActiveRecord::Migration
  def change
	add_column :relationships, :start_date_type, :string
  	add_column :relationships, :end_date_type, :string
  end
end
