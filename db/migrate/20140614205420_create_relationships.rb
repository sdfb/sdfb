class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :original_certainty
      t.integer :person1_index
      t.integer :person2_index
      t.integer :created_by
      t.integer :max_certainty
      t.integer :start_year
      t.string :start_month
      t.integer :start_day
      t.integer :end_year
      t.string :end_month
      t.integer :end_day
      t.text :justification
      t.integer :approved_by
      t.datetime :approved_on
      t.text :types_list, :default => [].to_yaml
      t.integer :edge_birthdate_certainty
      t.boolean :is_approved, :default => false
      t.boolean :is_active, :default => true
      t.boolean :is_rejected, :default => false
      t.text :edited_by_on, :default => [].to_yaml

      t.timestamps
    end

    execute("ALTER SEQUENCE relationships_id_seq START with 100200000 RESTART;")
  end
end
