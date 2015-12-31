class AddAnnotationToGroupCatAssigns < ActiveRecord::Migration
  def change
    add_column :group_cat_assigns, :annotation, :text
  end
end
