class AddAnnotationToRelationshipTypes < ActiveRecord::Migration
  def change
    add_column :relationship_types, :annotation, :text
  end
end
