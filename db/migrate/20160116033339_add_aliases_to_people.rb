class AddAliasesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :aliases, :text
  end
end
