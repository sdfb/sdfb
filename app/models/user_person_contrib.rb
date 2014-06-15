class UserPersonContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :is_flagged, :person_id
  
  # Relationships
  # -----------------------------
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :bibliography
  validates_presence_of :created_by
  validates_presence_of :is_flagged
  validates_presence_of :person_id
end
