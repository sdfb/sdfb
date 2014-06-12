class CreateUserPersonContribs < ActiveRecord::Migration
  def change
    create_table :user_person_contribs do |t|
      t.integer :person_id
      t.integer :created_by
      t.text :annotation
      t.text :bibliography
      t.boolean :is_flagged

      t.timestamps
    end
  end
end
