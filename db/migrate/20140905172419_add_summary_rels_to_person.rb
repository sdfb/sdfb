class AddSummaryRelsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :uncertain, :text
    add_column :people, :unlikely, :text
    add_column :people, :possible, :text
    add_column :people, :likely, :text
    add_column :people, :certain, :text
  end
end
