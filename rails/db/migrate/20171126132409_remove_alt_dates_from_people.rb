class RemoveAltDatesFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :alt_birth_year, :string
    remove_column :people, :alt_death_year, :string
  end
end
