class User < ActiveRecord::Base
  attr_accessible :about_description, :affiliation, :email, :first_name, :is_active, :is_admin, :last_name, :password_hash, :password_salt, :user_type
  has_many :user_rel_contribs
end
