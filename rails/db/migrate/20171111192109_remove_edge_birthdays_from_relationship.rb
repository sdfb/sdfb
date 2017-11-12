class RemoveEdgeBirthdaysFromRelationship < ActiveRecord::Migration
  def change
    remove_column :relationships, :edge_birthdate_certainty, :integer
  end
end
