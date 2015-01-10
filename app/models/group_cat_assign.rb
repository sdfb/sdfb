class GroupCatAssign < ActiveRecord::Base
  attr_accessible :group_category_id, :group_id, :created_by, :created_at, :approved_by, :approved_on, :is_approved,
  :is_active, :is_rejected, :edited_by_on
  serialize :edited_by_on,Array

  # Relationships
  # -----------------------------
  belongs_to :user
  belongs_to :group
  belongs_to :group_category

  # Validations
  # -----------------------------
  validates_presence_of :group_category_id
  validates_presence_of :group_id
  validates_presence_of :created_by

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_unapproved, where("approved_by is null")
  scope :for_group, lambda {|group_id_input| where('group_id = ?', "#{group_id_input}") }
  scope :for_group_category, lambda {|group_category_id_input| where('group_category_id = ?', "#{group_category_id_input}") }

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