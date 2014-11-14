class CreateRelationshipCategories < ActiveRecord::Migration
  def change
    create_table :relationship_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
