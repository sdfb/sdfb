class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :created_by
      t.string :name
      t.text :description
      t.text :justification
      t.string :approved_by
      t.string :approved_on
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
