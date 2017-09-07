class CreateRelCatAssigns < ActiveRecord::Migration
  def change
    create_table :rel_cat_assigns do |t|
      t.integer :relationship_category_id
      t.integer :relationship_type_id
     	t.integer :created_by
		  t.string :approved_by
		  t.string :approved_on
		  t.boolean :is_approved, :default => false
      t.boolean :is_active, :default => true
      t.boolean :is_rejected, :default => false
      t.text :edited_by_on, :default => [].to_yaml

      t.timestamps
    end
  end
end
