class AddBibliographyToPeople < ActiveRecord::Migration
  def change
    add_column :people, :bibliography, :text
  end
end
