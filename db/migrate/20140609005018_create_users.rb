class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.string :user_type
      t.string :affiliation
      t.boolean :is_admin
      t.text :about_description
      t.boolean :is_active

      t.timestamps
    end
  end
end
