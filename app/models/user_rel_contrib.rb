class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence, :created_by, :relationship_id, :relationship_type, 
  :approved_by, :approved_on, :created_at, :is_approved
  
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

  ###need rel type for directional
  ###need inverse rel type for directional

  # Validations
  # -----------------------------
  validates :relationship_type, :inclusion => {:in =>  REL_TYPE_LIST}, :allow_blank => true
  validates_presence_of :annotation
  validates_presence_of :confidence
  validates_presence_of :created_by
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_for_relationship, lambda {|relID| 
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}

  # Callbacks
  # ----------------------------- 
  before_create :check_if_approved
  before_update :check_if_approved


  # Custom Methods
  # -----------------------------
  def check_if_approved
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end


  def annot_present?
    !annotation.nil?
  end

  def bib_present?
    !bibliography.nil?
  end

  def get_person1_name
    return Person.find(Relationship.find(relationship_id).person1_index).first_name + " " + Person.find(Relationship.find(relationship_id).person1_index).last_name 
  end

  def get_person2_name
    return Person.find(Relationship.find(relationship_id).person2_index).first_name + " " + Person.find(Relationship.find(relationship_id).person2_index).last_name 
  end

  def get_both_names
    return Person.find(Relationship.find(relationship_id).person1_index).first_name + " " + Person.find(Relationship.find(relationship_id).person1_index).last_name + " & " + Person.find(Relationship.find(relationship_id).person2_index).first_name + " " + Person.find(Relationship.find(relationship_id).person2_index).last_name 
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
