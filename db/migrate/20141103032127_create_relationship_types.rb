class CreateRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :relationship_types do |t|
      t.integer :relationship_type_inverse
      t.integer :default_rel_category
      t.string :name
      t.text :description
      t.boolean :is_active, :default => true
      t.integer :approved_by
      t.datetime :approved_on
      t.boolean :is_approved, :default => false
      t.integer :created_by

      t.timestamps
    end
    execute("ALTER SEQUENCE relationship_types_id_seq START with 103 RESTART;")
  end
end
