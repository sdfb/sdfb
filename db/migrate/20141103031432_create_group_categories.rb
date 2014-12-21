class CreateGroupCategories < ActiveRecord::Migration
  def change
    create_table :group_categories do |t|
      t.string :name
      t.text :description
      t.integer :created_by
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
