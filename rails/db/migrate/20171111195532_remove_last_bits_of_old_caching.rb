class RemoveLastBitsOfOldCaching < ActiveRecord::Migration
  def change
    remove_column :people, :group_list, :text, :default => [].to_yaml
    remove_column :people, :rel_sum, :text, :default => [].to_yaml
  end
end
