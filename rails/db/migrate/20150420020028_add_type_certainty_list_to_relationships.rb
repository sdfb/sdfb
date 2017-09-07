class AddTypeCertaintyListToRelationships < ActiveRecord::Migration
  def change
  	add_column :relationships, :type_certainty_list, :text, :default => [].to_yaml
  end
end
