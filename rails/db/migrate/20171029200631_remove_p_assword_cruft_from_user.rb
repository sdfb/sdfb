class RemovePAsswordCruftFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :password_salt, :string
    remove_column :users, :password_hash, :string
    remove_column :users, :password, :string
    remove_column :users, :password_confirmation, :string
  end
end
