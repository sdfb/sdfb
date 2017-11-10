class RemoveDefaultRelCategoryFromRelationshipType < ActiveRecord::Migration
  def change
    remove_column :relationship_types, :default_rel_category, :integer

  end
end
