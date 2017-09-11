class AddIndexToRelationshipIds < ActiveRecord::Migration
  def change
    add_index :relationships, :person1_index
    add_index :relationships, :person2_index
  end
end
