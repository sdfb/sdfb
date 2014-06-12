class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :original_id
      t.string :first_name
      t.string :last_name
      t.integer :created_by
      t.integer :birth_year
      t.integer :death_year
      t.text :historical_significance
      t.boolean :is_approved

      t.timestamps
    end
  end
end
