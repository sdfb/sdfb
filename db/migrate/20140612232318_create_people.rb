class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.integer :created_by
      t.text :historical_significance
      t.text :rel_sum, :default => [].to_yaml
      t.string :prefix
      t.string :suffix
      t.string :search_names_all
      t.string :title
      t.string :birth_year_type
      t.string :ext_birth_year
      t.string :alt_birth_year
      t.string :death_year_type
      t.string :ext_death_year
      t.string :alt_death_year
      t.text :justification
      t.integer :approved_by
      t.datetime :approved_on
      t.integer :odnb_id
      t.boolean :is_approved, :default => false
      t.timestamps
    end

    execute("ALTER SEQUENCE people_id_seq START with 11000000 RESTART;")
  end
end
