class RemoveTypesListFromRelationship < ActiveRecord::Migration
  def change
    remove_column :relationships, :types_list, :text, :default => [].to_yaml
  end
end
