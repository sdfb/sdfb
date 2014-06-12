class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :created_by
      t.string :name
      t.text :description
      t.boolean :is_approved

      t.timestamps
    end
  end
end
