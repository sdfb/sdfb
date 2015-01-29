class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :about_description
      t.string :affiliation
      t.string :email
      t.string :first_name
      t.boolean :is_active
      t.string :last_name
      t.string :password
      t.string :password_confirmation
      t.string :password_hash
      t.string :password_salt
      t.string :user_type
      t.string :prefix
      t.string :orcid
      t.integer :created_by
      t.boolean :is_curator, :default => false
      t.boolean :curator_revoked, :default => false
      t.string :username

      t.timestamps
    end
  end
end
