class AddLastEditToAll < ActiveRecord::Migration
  def change
    add_column :groups, :last_edit, :text, :default => [].to_yaml
    add_column :group_assignments, :last_edit, :text, :default => [].to_yaml
    add_column :group_cat_assigns, :last_edit, :text, :default => [].to_yaml
    add_column :group_categories, :last_edit, :text, :default => [].to_yaml
    add_column :people, :last_edit, :text, :default => [].to_yaml
    add_column :rel_cat_assigns, :last_edit, :text, :default => [].to_yaml
    add_column :relationships, :last_edit, :text, :default => [].to_yaml
    add_column :relationship_categories, :last_edit, :text, :default => [].to_yaml
    add_column :relationship_types, :last_edit, :text, :default => [].to_yaml
    add_column :user_group_contribs, :last_edit, :text, :default => [].to_yaml
    add_column :user_person_contribs, :last_edit, :text, :default => [].to_yaml
    add_column :user_rel_contribs, :last_edit, :text, :default => [].to_yaml
  end
end
