class AddBibliographyToRelationshipCategories < ActiveRecord::Migration
  def change
    add_column :relationship_categories, :bibliography, :text
  end
end
