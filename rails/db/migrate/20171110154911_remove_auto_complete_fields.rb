class RemoveAutoCompleteFields < ActiveRecord::Migration
  def change
    remove_column :user_person_contribs, :person_autocomplete, :string
    remove_column :user_rel_contribs, :person1_autocomplete, :string
    remove_column :user_rel_contribs, :person2_autocomplete, :string
    remove_column :user_rel_contribs, :person1_selection, :string
    remove_column :user_rel_contribs, :person2_selection, :string
    remove_column :relationships, :person1_autocomplete, :string
    remove_column :relationships, :person2_autocomplete, :string
    remove_column :group_assignments, :person_autocomplete, :string
  end
end
