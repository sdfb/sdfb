class AddContentToComment < ActiveRecord::Migration
  def up
	remove_column :comments, :description
	add_column :comments, :content, :text
  end

  def down
  end
end
