class CreateRelCatAssigns < ActiveRecord::Migration
  def change
    create_table :rel_cat_assigns do |t|
      t.integer :relationship_category_id
      t.integer :relationship_type_id

      t.timestamps
    end
  end
end
