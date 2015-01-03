class CreateRelationshipCategories < ActiveRecord::Migration
  def change
    create_table :relationship_categories do |t|
      t.string :name
      t.text :description
      t.boolean :is_approved, :default => false
      t.integer :approved_by
      t.datetime :approved_on
      t.integer :created_by

      t.timestamps
    end
  end
end
