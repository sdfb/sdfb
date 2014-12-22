class UserPersonContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :person_id, :approved_by,
  :approved_on, :created_at, :is_approved

  # Relationships
  # -----------------------------
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :created_by
  validates_presence_of :person_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_for_person, lambda {|personID| 
      select('user_person_contribs.*')
      .where('person_id = ?', personID)}

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

  def get_person_name
    return Person.find(person_id).first_name + " " + Person.find(person_id).last_name 
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
