class AddBibliographyToGroupCatAssigns < ActiveRecord::Migration
  def change
    add_column :group_cat_assigns, :bibliography, :text
  end
end
