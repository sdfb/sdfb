class AddBibliographyToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :bibliography, :text
  end
end
