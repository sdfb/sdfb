class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :is_approved, :name
end
