class MakeBibliographyCitation < ActiveRecord::Migration
  def change
    rename_column :group_assignments, :bibliography, :citation
    rename_column :groups, :bibliography, :citation
    rename_column :people, :bibliography, :citation
    rename_column :rel_cat_assigns, :bibliography, :citation
    rename_column :relationship_categories, :bibliography, :citation
    rename_column :relationship_types, :bibliography, :citation
    rename_column :relationships, :bibliography, :citation
    rename_column :user_rel_contribs, :bibliography, :citation
  end
end
