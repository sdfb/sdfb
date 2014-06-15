class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :is_approved, :name
  
  # Relationships
  # -----------------------------
  has_many :people, :through => :group_assignments
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :created_by
  validates_presence_of :is_approved
end
