class AddAutocompleteFields < ActiveRecord::Migration
  def change
  	add_column :user_person_contribs, :person_autocomplete, :string
  end
end
