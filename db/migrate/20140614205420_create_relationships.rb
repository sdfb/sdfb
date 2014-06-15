class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.decimal :average_certainty
      t.boolean :is_approved
      t.decimal :original_certainty
      t.integer :person1_index
      t.integer :person2_index
      t.integer :created_by

      t.timestamps
    end
  end
end
