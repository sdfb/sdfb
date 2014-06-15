class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :password
      t.string :password_confirmation
      t.text :about_description
      t.string :affiliation
      t.string :email
      t.string :first_name
      t.boolean :is_active
      t.string :last_name
      t.string :password_hash
      t.string :password_salt
      t.string :user_type

      t.timestamps
    end
  end
end
