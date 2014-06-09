class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string, :name
      t.text, :description
      t.integer :created_by

      t.timestamps
    end
  end
end
