class RemoveIsLockedFromUserRelContribs < ActiveRecord::Migration
  def change
    remove_column :user_rel_contribs, :is_locked, :boolean

  end
end
