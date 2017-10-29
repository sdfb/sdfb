class RemoveIsCuratorFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :is_curator, :boolean
  end
end
