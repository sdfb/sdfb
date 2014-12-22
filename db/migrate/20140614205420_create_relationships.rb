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
      t.datetime :approved_on
      t.integer :edge_birthdate_certainty
      t.boolean :is_approved, :default => false

      t.timestamps
    end

    execute("ALTER SEQUENCE relationships_id_seq START with 200000 RESTART;")
  end
end
