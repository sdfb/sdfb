class CreateRelationshipCategories < ActiveRecord::Migration
  def change
    create_table :relationship_categories do |t|
      t.string :name
      t.text :description
      t.boolean :is_approved, :default => false
      t.integer :approved_by
      t.datetime :approved_on
      t.integer :created_by
      t.boolean :is_active, :default => true
      t.boolean :is_rejected, :default => false
      t.text :edited_by_on, :default => [].to_yaml

      t.timestamps
    end
    execute("ALTER SEQUENCE relationship_categories_id_seq START with 9 RESTART;")
  end
end
