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

    odnb_admin = User.new
    odnb_admin.first_name = "ODNB"
    odnb_admin.last_name = "Admin"
    odnb_admin.email = "odnb_admin@example.com"
    odnb_admin.password = "admin"
    odnb_admin.password_confirmation = "admin"
    odnb_admin.user_type = "Admin"
    odnb_admin.is_active = true
    odnb_admin.username = "ODNB_Admin"
    odnb_admin.curator_revoked = false
    odnb_admin.save!

    sdfb_admin = User.new
    sdfb_admin.first_name = "SDFB"
    sdfb_admin.last_name = "Admin"
    sdfb_admin.email = "sdfb_admin@example.com"
    sdfb_admin.password = "admin"
    sdfb_admin.password_confirmation = "admin"
    sdfb_admin.user_type = "Admin"
    sdfb_admin.is_active = true
    sdfb_admin.username = "SDFB_Admin"
    sdfb_admin.curator_revoked = false
    sdfb_admin.save!
  end

  def down
  	admin = User.find_by_email "admin@example.com"
    User.delete admin
  end
end
