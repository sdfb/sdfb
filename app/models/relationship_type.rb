class RelationshipType < ActiveRecord::Base
  attr_accessible :default_rel_category, :description, :is_active, :name, :relationship_type_inverse, 
  :created_at, :is_approved, :approved_by, :approved_on, :created_by, :is_active, :is_rejected, :edited_by_on
  serialize :edited_by_on,Array

  # Relationships
  # -----------------------------
  has_many :relationships, :through => :rel_cat_assigns
  #belongs_to :relationship_type_inverse

  # Validations
  # -----------------------------
  #validates_presence_of :default_rel_category
  validates :is_active, :inclusion => {:in => [true, false]}
  validates_presence_of :name
  #validates_presence_of :relationship_type_inverse
  ## name must be at least 4 character
  validates_length_of :name, :minimum => 3, :if => :name_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")

  # Callbacks
  # ----------------------------- 
  before_create :check_if_approved
  before_update :check_if_approved
  before_create :init_array
  before_update :add_editor_to_edit_by_on

  # Custom Methods
  # -----------------------------
  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = RelationshipType.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.edited_by_on)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end
  end

  def init_array
    self.edited_by_on = nil
  end

  def name_present?
    !name.nil?
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end
