class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence_type, :created_by, :is_flagged, :relationship_id, :relationship_type
  
  # Relationships
  # -----------------------------
  belongs_to :relationship
  belongs_to :user

  # Misc Constants
  # -----------------------------
  REL_TYPE_LIST = ["No relationship exists", "Acquaintances","Ancestor/Descendent","Antagonists","Mentor/Apprentice","Parent/Child","Close Friends","Collaborators",
    "Colleagues","Employer/Employee","Enemies","Engaged","Friends","Grandparent/Grandchild","Met",
    "Influenced one another","Knew in passing","Knew of one another","Life partners","Lived with",
    "Neighbors","Siblings","Spouses","Coworkers"]

  USER_EST_CONFIDENCE_LIST = ["Certain", "Highly Likely", "Possible", "Unlikely", "Very Unlikely"]

  # Validations
  # -----------------------------
  validates :relationship_type, :inclusion => {:in =>  REL_TYPE_LIST}, :allow_blank => true
  validates :confidence_type, :inclusion => {:in => USER_EST_CONFIDENCE_LIST}
  validates_presence_of :annotation
  validates_presence_of :bibliography
  validates_presence_of :confidence_type
  validates_presence_of :created_by
  validates_presence_of :is_flagged
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type
end
