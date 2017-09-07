class AddBibliographyToRelCatAssigns < ActiveRecord::Migration
  def change
    add_column :rel_cat_assigns, :bibliography, :text
  end
end
