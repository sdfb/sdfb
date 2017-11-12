class RemoveAnnotationFromEverything < ActiveRecord::Migration
  def change
    remove_column :user_group_contribs, :annotation, :text
    remove_column :group_assignments, :annotation, :text
    remove_column :group_cat_assigns, :annotation, :text
    remove_column :group_categories, :annotation, :text
    remove_column :rel_cat_assigns, :annotation, :text
    remove_column :relationship_categories, :annotation, :text
    remove_column :relationship_types, :annotation, :text
    remove_column :user_person_contribs, :annotation, :text
    remove_column :user_rel_contribs, :annotation, :text
  end
end
