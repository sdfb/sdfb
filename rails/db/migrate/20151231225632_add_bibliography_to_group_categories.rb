class AddBibliographyToGroupCategories < ActiveRecord::Migration
  def change
    add_column :group_categories, :bibliography, :text
  end
end
