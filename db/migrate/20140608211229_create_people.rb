class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string, :name
      t.integer, :created_by
      t.integer, :birth_year
      t.integer, :death_year
      t.text :historical_significance

      t.timestamps
    end
  end
end
