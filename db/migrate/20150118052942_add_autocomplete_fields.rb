class AddAutocompleteFields < ActiveRecord::Migration
  def change
  	add_column :user_person_contribs, :person_autocomplete, :string
  	add_column :user_rel_contribs, :person1_autocomplete, :string
  	add_column :user_rel_contribs, :person2_autocomplete, :string
  	add_column :user_rel_contribs, :person1_selection, :string
  	add_column :user_rel_contribs, :person2_selection, :string
  end
end
