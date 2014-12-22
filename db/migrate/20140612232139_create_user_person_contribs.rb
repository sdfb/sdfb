class CreateUserPersonContribs < ActiveRecord::Migration
  def change
    create_table :user_person_contribs do |t|
      t.integer :person_id
      t.integer :created_by
      t.text :annotation
      t.text :bibliography
      t.integer :approved_by
      t.date :approved_on
      t.boolean :is_approved, :default => false

      t.timestamps
    end
  end
end
