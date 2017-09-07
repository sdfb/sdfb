class AddIsLockedUserRelContrib < ActiveRecord::Migration
  def change
  	add_column :user_rel_contribs, :is_locked, :boolean, :default => false
  end
end
