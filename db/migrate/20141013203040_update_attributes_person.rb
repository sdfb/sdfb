class UpdateAttributesPerson < ActiveRecord::Migration
  def up
  	remove_column :people, :birth_year
  	remove_column :people, :death_year
  	add_column :people, :prefix, :string
  	add_column :people, :suffix, :string
  	add_column :people, :search_names_all, :string
  	add_column :people, :title, :string
  	add_column :people, :birth_year_type, :date
  	add_column :people, :ext_birth_year, :date
  	add_column :people, :alt_birth_year, :date
  	add_column :people, :death_year_type, :string
  	add_column :people, :ext_death_year, :date
  	add_column :people, :alt_death_year, :date
  	add_column :people, :justification, :text
  	add_column :people, :approved_by, :integer
  	add_column :people, :approved_on, :datetime
  end

  def down
  end
end