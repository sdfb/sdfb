class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :created_by
      t.string :name
      t.text :description
      t.text :justification
      t.integer :start_year
      t.integer :end_year
      t.string :approved_by
      t.string :approved_on
      t.boolean :is_approved, :default => false
      t.text :person_list, :default => [].to_yaml

      t.timestamps
    end
    execute("ALTER SEQUENCE groups_id_seq START with 76 RESTART;")
  end
end
