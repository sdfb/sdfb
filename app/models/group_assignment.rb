class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :is_approved, :person_id
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by
  validates_presence_of :is_approved
end
