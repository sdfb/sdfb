class DeleteMaxUserRelEditfromRelationship < ActiveRecord::Migration
  def change
  	remove_column :relationships, :max_user_rel_edit
  end
end
