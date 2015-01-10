class GroupCategory < ActiveRecord::Base
  attr_accessible :description, :name, :created_by, :created_at, :is_approved, :approved_on,
  :approved_by, :is_active, :is_rejected, :edited_by_on
  serialize :edited_by_on,Array

  # Relationships
  # -----------------------------
  belongs_to :user

  # Validations
  # -----------------------------
  #validates_presence_of :description
  validates_presence_of :name
  validates_presence_of :created_by

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_unapproved, where("approved_by is null") 

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
  
  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end