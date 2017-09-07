class AddDateTypeToUserRelContrib < ActiveRecord::Migration
  def change
  	add_column :user_rel_contribs, :start_date_type, :string
  	add_column :user_rel_contribs, :end_date_type, :string
  end
end
