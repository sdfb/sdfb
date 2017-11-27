class RenameExDatesForPeople < ActiveRecord::Migration
  def change
    rename_column :people, :ext_birth_year, :birth_year
    rename_column :people, :ext_death_year, :death_year
  end
end
