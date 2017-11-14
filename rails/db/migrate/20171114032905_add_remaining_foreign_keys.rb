class AddRemainingForeignKeys < ActiveRecord::Migration
  def change
    add_index :rel_cat_assigns, :relationship_category_id
    add_index :rel_cat_assigns, :relationship_type_id
    add_index :relationship_types, :relationship_type_inverse
    add_index :user_rel_contribs, :relationship_type_id

  end
end
