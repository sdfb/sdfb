class CreateGroupCatAssigns < ActiveRecord::Migration
  def change
    create_table :group_cat_assigns do |t|
		t.integer :group_id
		t.integer :group_category_id
		t.integer :created_by
		t.string :approved_by
		t.string :approved_on
		t.boolean :is_approved, :default => false
		t.boolean :is_active, :default => true
      	t.boolean :is_rejected, :defailt => false
      	t.text :edited_by_on, :default => [].to_yaml
		t.timestamps
    end
  end
end
