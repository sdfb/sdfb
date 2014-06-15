class UserGroupContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :group_id, :is_flagged
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :bibliography
  validates_presence_of :created_by
  validates_presence_of :group_id
  validates_presence_of :is_flagged
  validates_uniqueness_of :email
end
