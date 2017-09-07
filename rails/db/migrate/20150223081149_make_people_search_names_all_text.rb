class MakePeopleSearchNamesAllText < ActiveRecord::Migration
  def change
  	remove_column :people, :search_names_all
  	add_column :people, :search_names_all, :text
  end
end
