class AddAnnotationToRelCatAssigns < ActiveRecord::Migration
  def change
    add_column :rel_cat_assigns, :annotation, :text
  end
end
