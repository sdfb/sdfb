class AddAdmin < ActiveRecord::Migration
  def up
  	admin = User.new
    admin.first_name = "Katarina"
    admin.last_name = "Shaw"
    admin.email = "admin@example.com"
    admin.password = "admin"
    admin.password_confirmation = "admin"
    admin.user_type = "Admin"
    admin.is_active = true
    admin.username = "KatAdmin"
    admin.curator_revoked = false
    admin.save!
  end

  def down
  	admin = User.find_by_email "admin@example.com"
    User.delete admin
  end
end
