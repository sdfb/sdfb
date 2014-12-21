class UserGroupContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :group_id, :created_by, :approved_by,
  :approved_on, :created_at, :is_approved

  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :created_by
  validates_presence_of :group_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?


  # Scope
  # -----------------------------
  #broken since there is no is_falgged
  ##scope :not_flagged, where(is_flagged: false)

  # Callbacks
  # ----------------------------- 
  before_create :check_if_approved
  before_update :check_if_approved

  # Custom Methods
  # -----------------------------
  def get_group_name
    return Group.find(group_id)
  end

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

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
