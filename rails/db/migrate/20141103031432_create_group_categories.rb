class CreateGroupCategories < ActiveRecord::Migration
  def change
    create_table :group_categories do |t|
		t.string :name
		t.text :description
		t.integer :created_by
		t.string :approved_by
		t.string :approved_on
		t.boolean :is_approved, :default => false
		t.boolean :is_active, :default => true
      	t.boolean :is_rejected, :default => false
      	t.text :edited_by_on, :default => [].to_yaml
		t.timestamps
    end
    execute("ALTER SEQUENCE group_categories_id_seq START with 7 RESTART;")
  end
end
