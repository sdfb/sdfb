class AddRelSumToPeople < ActiveRecord::Migration
  def change
    add_column :people, :rel_sum, :text, :default => [].to_yaml
  end
end
