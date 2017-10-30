class ChangeUserTypeInUser < ActiveRecord::Migration
  def change
    change_column :users, :user_type, :string, :default => "Standard"
    change_column :users, :is_active, :boolean, :default => true
  end
end
