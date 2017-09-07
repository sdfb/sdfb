class AddBibliographyToRelationshipTypes < ActiveRecord::Migration
  def change
    add_column :relationship_types, :bibliography, :text
  end
end
