class RemoveRejectedFromCode < ActiveRecord::Migration
  def change
    remove_column :group_assignments, :is_rejected, :boolean, default: false
    remove_column :group_cat_assigns, :is_rejected, :boolean, default: false
    remove_column :group_categories, :is_rejected, :boolean, default: false
    remove_column :groups, :is_rejected, :boolean, default: false
    remove_column :people, :is_rejected, :boolean, default: false
    remove_column :rel_cat_assigns, :is_rejected, :boolean, default: false
    remove_column :relationship_categories, :is_rejected, :boolean, default: false
    remove_column :relationship_types, :is_rejected, :boolean, default: false
    remove_column :relationships, :is_rejected, :boolean, default: false
    remove_column :user_group_contribs, :is_rejected, :boolean, default: false
    remove_column :user_person_contribs, :is_rejected, :boolean, default: false
    remove_column :user_rel_contribs, :is_rejected, :boolean, default: false
  end
end
