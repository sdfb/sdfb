class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence, :created_by, :relationship_id, :relationship_type_id, 
  :approved_by, :approved_on, :created_at, :is_approved, :start_year, :start_month, 
  :start_day, :end_year, :end_month, :end_day, :is_active, :is_rejected, :edited_by_on
  serialize :edited_by_on,Array
  
  # Relationships
  # -----------------------------
  belongs_to :relationship
  belongs_to :relationship_type
  belongs_to :user

  # Misc Constants
  # -----------------------------
  USER_EST_CONFIDENCE_LIST = ["Certain", "Highly Likely", "Possible", "Unlikely", "Very Unlikely"]

  ###need rel type for directional
  ###need inverse rel type for directional

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :confidence
  validates_presence_of :created_by
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?
  validates :start_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :start_year_present?
  validates :start_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :start_year_present?
  validates :end_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :end_year_present?
  validates :end_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :end_year_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_unapproved, where("approved_by is null")
  scope :all_for_relationship, lambda {|relID| 
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}

  # Callbacks
  # ----------------------------- 
  before_create :check_if_approved
  before_update :check_if_approved
  before_create :init_array


  # Custom Methods
  # -----------------------------
  def init_array
    self.edited_by_on = nil
  end
  
  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def annot_present?
    ! self.annotation.blank?
  end

  def bib_present?
    ! self.bibliography.blank?
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
