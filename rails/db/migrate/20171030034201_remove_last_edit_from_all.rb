class RemoveLastEditFromAll < ActiveRecord::Migration
  def change
    remove_column :groups, :last_edit, :text, :default => [].to_yaml
    remove_column :group_assignments, :last_edit, :text, :default => [].to_yaml
    remove_column :group_cat_assigns, :last_edit, :text, :default => [].to_yaml
    remove_column :group_categories, :last_edit, :text, :default => [].to_yaml
    remove_column :people, :last_edit, :text, :default => [].to_yaml
    remove_column :rel_cat_assigns, :last_edit, :text, :default => [].to_yaml
    remove_column :relationships, :last_edit, :text, :default => [].to_yaml
    remove_column :relationship_categories, :last_edit, :text, :default => [].to_yaml
    remove_column :relationship_types, :last_edit, :text, :default => [].to_yaml
    remove_column :user_group_contribs, :last_edit, :text, :default => [].to_yaml
    remove_column :user_person_contribs, :last_edit, :text, :default => [].to_yaml
    remove_column :user_rel_contribs, :last_edit, :text, :default => [].to_yaml
  end
end
