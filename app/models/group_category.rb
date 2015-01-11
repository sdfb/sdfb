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
  before_update :add_editor_to_edit_by_on

  # Custom Methods
  # -----------------------------
  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = GroupCategory.find(self.id).edited_by_on
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
  
  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end