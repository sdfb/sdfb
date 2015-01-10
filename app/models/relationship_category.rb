class RelationshipCategory < ActiveRecord::Base
  attr_accessible :description, :name, :created_at, :is_approved, :created_by, :approved_by, :approved_on,
  :is_active, :is_rejected, :edited_by_on
  serialize :edited_by_on,Array

  # Relationships
  # -----------------------------
  has_many :relationships, :through => :rel_cat_assigns

  # Validations
  # -----------------------------
  validates_presence_of :name

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
  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def init_array
    self.edited_by_on = nil
  end
end
