class Person < ActiveRecord::Base
  attr_accessible :birth_year, :created_by, :death_year, :first_name, :historical_significance, :is_approved, :last_name, :original_id
  has_many :groups, :through => :group_assignments
  belongs_to :user
end
