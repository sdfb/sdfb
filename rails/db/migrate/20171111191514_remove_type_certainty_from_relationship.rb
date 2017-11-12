class RemoveTypeCertaintyFromRelationship < ActiveRecord::Migration
  def change
    remove_column :relationships, :type_certainty_list, :text, :default => [].to_yaml
  end
end
