class AddIsPublicToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_public, :boolean, :default => false
    User.reset_column_information
    User.update_all(is_public: false)
  end
end
