class UpdateAttributesUser < ActiveRecord::Migration
   def up
      remove_column :users, :is_admin
      remove_column :users, :prefix
      remove_column :users, :created_by
      remove_column :users, :is_curator
      add_column :users, :prefix, :string
      add_column :users, :orcid, :string
      add_column :users, :created_by, :integer
      add_column :users, :is_curator, :boolean, :default => false
      add_column :users, :curator_revoked, :boolean, :default => false
      add_column :users, :username, :string
   end

   def down
   end
end




