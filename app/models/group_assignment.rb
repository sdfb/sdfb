class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :is_approved, :person_id
  belongs_to :group
  belongs_to :person
  belongs_to :user
end
