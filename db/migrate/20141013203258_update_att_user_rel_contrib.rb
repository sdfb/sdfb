class UpdateAttUserRelContrib < ActiveRecord::Migration
  def up
  	remove_column :user_rel_contribs, :is_flagged
  	add_column :user_rel_contribs, :edited_by_on, :text, :default => [].to_yaml
  	add_column :user_rel_contribs, :reviewed_by_on, :text, :default => [].to_yaml
  end

  def down
  end
end
