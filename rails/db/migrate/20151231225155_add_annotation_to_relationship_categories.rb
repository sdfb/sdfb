class AddAnnotationToRelationshipCategories < ActiveRecord::Migration
  def change
    add_column :relationship_categories, :annotation, :text
  end
end
