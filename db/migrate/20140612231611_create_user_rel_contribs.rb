class CreateUserRelContribs < ActiveRecord::Migration
  def change
    create_table :user_rel_contribs do |t|
      t.integer :relationship_id
      t.integer :created_by
      t.decimal :confidence
      t.text :annotation
      t.text :bibliography
      t.string :relationship_type
      t.integer :approved_by
      t.date :approved_on
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
