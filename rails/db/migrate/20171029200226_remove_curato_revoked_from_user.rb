class RemoveCuratoRevokedFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :curator_revoked, :boolean
  end
end
