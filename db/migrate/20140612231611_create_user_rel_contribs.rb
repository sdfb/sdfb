class CreateUserRelContribs < ActiveRecord::Migration
  def change
    create_table :user_rel_contribs do |t|
      t.integer :relationship_id
      t.integer :created_by
      t.string :confidence_type
      t.text :annotation
      t.text :bibliography
      t.string :relationship_type
      t.text :edited_by_on, :default => [].to_yaml
      t.text :reviewed_by_on, :default => [].to_yaml

      t.timestamps
    end
  end
end
