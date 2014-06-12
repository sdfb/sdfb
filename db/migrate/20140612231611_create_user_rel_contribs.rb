class CreateUserRelContribs < ActiveRecord::Migration
  def change
    create_table :user_rel_contribs do |t|
      t.integer :relationship_id
      t.integer :created_by
      t.string :confidence_type
      t.text :annotation
      t.text :bibliography
      t.string :relationship_type
      t.boolean :is_flagged

      t.timestamps
    end
  end
end
