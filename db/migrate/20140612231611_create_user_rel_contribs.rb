class CreateUserRelContribs < ActiveRecord::Migration
  def change
    create_table :user_rel_contribs do |t|
      t.integer :relationship_id
      t.integer :created_by
      t.integer :confidence
      t.text :annotation
      t.text :bibliography
      t.integer :relationship_type_id
      t.integer :start_year
      t.string :start_month
      t.integer :start_day
      t.integer :end_year
      t.string :end_month
      t.integer :end_day
      t.integer :approved_by
      t.date :approved_on
      t.boolean :is_approved, :default => true

      t.timestamps
    end
  end
end
