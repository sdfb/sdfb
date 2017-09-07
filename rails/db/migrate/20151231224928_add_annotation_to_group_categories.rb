class AddAnnotationToGroupCategories < ActiveRecord::Migration
  def change
    add_column :group_categories, :annotation, :text
  end
end
