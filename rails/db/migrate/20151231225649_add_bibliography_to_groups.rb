class AddBibliographyToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :bibliography, :text
  end
end
