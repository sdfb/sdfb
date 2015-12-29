class AddAdmin < ActiveRecord::Migration
  def up
  end

  def down
  	admin = User.find_by_email "admin@example.com"
    User.delete admin
  end
end
