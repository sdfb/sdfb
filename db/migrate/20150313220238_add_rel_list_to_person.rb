class AddRelListToPerson < ActiveRecord::Migration
  def change
  	add_column :people, :rel_list, :text, :default => [].to_yaml
  end
end
