class AddIndexToUserRelContribs < ActiveRecord::Migration
  def change
    add_index :user_rel_contribs, :relationship_id
  end
end
