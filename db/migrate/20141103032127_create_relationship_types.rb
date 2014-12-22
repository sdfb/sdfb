class CreateRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :relationship_types do |t|
      t.integer :relationship_type_inverse_id
      t.integer :default_rel_category
      t.string :name
      t.text :description
      t.boolean :is_active, :default => true
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
