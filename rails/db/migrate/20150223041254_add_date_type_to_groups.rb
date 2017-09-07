class AddDateTypeToGroups < ActiveRecord::Migration
  def change
  	add_column :groups, :start_date_type, :string
  	add_column :groups, :end_date_type, :string
  end
end
