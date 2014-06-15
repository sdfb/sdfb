class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :is_approved, :name
  has_many :people, :through => :group_assignments
  belongs_to :user
end
