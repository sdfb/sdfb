class AddMaxUserRelEditToRelationships < ActiveRecord::Migration
  def change
  	add_column :relationships, :max_user_rel_edit, :integer
  end
end
