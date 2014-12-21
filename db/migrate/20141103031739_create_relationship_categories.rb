class CreateRelationshipCategories < ActiveRecord::Migration
  def change
    create_table :relationship_categories do |t|
      t.string :name
      t.text :description
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
