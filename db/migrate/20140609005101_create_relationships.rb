class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :person1_index
      t.integer :person2_index
      t.decimal :original_certainty

      t.timestamps
    end
  end
end
