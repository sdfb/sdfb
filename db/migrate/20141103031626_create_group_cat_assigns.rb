class CreateGroupCatAssigns < ActiveRecord::Migration
  def change
    create_table :group_cat_assigns do |t|
      t.integer :group_id
      t.integer :group_category_id

      t.timestamps
    end
  end
end
