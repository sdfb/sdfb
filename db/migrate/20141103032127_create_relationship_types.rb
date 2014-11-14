class CreateRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :relationship_types do |t|
      t.integer :relationship_type_inverse_id
      t.integer :default_rel_category
      t.string :name
      t.text :description
      t.boolean :is_active

      t.timestamps
    end
  end
end
