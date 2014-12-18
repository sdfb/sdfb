class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.decimal :original_certainty
      t.integer :person1_index
      t.integer :person2_index
      t.integer :created_by
      t.decimal :max_certainty
      t.date :start_date
      t.date :end_date
      t.text :justification
      t.integer :approved_by
      t.datetime :approved_by
      t.integer :edge_birthdate_certainty

      t.timestamps
    end
  end
end
