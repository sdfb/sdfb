class AddCreatedByIndexes < ActiveRecord::Migration
  def change
    add_index :group_assignments, :created_by
    add_index :groups, :created_by
    add_index :people, :created_by
    add_index :rel_cat_assigns, :created_by
    add_index :relationship_categories, :created_by
    add_index :relationship_types, :created_by
    add_index :relationships, :created_by
    add_index :user_rel_contribs, :created_by
    add_index :users, :created_by

    add_index :group_assignments, :approved_by
    add_index :groups, :approved_by
    add_index :people, :approved_by
    add_index :rel_cat_assigns, :approved_by
    add_index :relationship_categories, :approved_by
    add_index :relationship_types, :approved_by
    add_index :relationships, :approved_by
    add_index :user_rel_contribs, :approved_by
  end
end
