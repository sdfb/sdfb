class DeleteEditByOn < ActiveRecord::Migration
  def up
    remove_column :groups, :edited_by_on
    remove_column :group_assignments, :edited_by_on
    remove_column :group_cat_assigns, :edited_by_on
    remove_column :group_categories, :edited_by_on
    remove_column :people, :edited_by_on
    remove_column :rel_cat_assigns, :edited_by_on
    remove_column :relationships, :edited_by_on
    remove_column :relationship_categories, :edited_by_on
    remove_column :relationship_types, :edited_by_on
    remove_column :user_group_contribs, :edited_by_on
    remove_column :user_person_contribs, :edited_by_on
    remove_column :user_rel_contribs, :edited_by_on
  end
end
