class RelationshipType < ActiveRecord::Base
  attr_accessible :default_rel_category, :description, :is_active, :name, :relationship_type_inverse, 
  :created_at, :is_approved, :approved_by, :approved_on, :created_by

  # Relationships
  # -----------------------------
  has_many :relationships, :through => :rel_cat_assigns

  # Validations
  # -----------------------------
  validates_presence_of :default_rel_category
  validates :is_active, :inclusion => {:in => [true, false]}
  validates_presence_of :name
  #validates_presence_of :relationship_type_inverse
  ## name must be at least 4 character
  validates_length_of :name, :minimum => 4, :if => :name_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")

  # Callbacks
  # ----------------------------- 
  before_create :check_if_approved
  before_update :check_if_approved

  # Custom Methods
  # -----------------------------

  def name_present?
    !name.nil?
  end

  def check_if_approved
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

end
