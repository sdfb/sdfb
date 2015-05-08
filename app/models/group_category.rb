class GroupCategory < ActiveRecord::Base
  attr_accessible :description, :name, :created_by, :created_at, :is_approved, :approved_on,
  :approved_by, :is_active, :is_rejected, :last_edit
  serialize :last_edit,Array

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
  scope :all_approved, where("is_approved is true and is_active is true and is_rejected is false")
  scope :all_inactive, where("is_active is false")
  scope :all_rejected, where("is_rejected is true and is_active is true")
  scope :all_unapproved, where("is_approved is false and is_rejected is false and is_active is true")
  scope :all_recent, order('created_at DESC')
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :alphabetical, order('name')
  scope :order_by_sdfb_id, order('id')
  scope :all_active_unrejected, where("is_active is true and is_rejected is false")

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :check_if_approved
  before_update :check_if_approved_and_update_edit

  # Custom Methods
  # -----------------------------
  def init_array
    self.last_edit = nil
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_and_update_edit
    new_last_edit = []
    new_last_edit.push(self.approved_by.to_i)
    new_last_edit.push(Time.now)
    self.last_edit = new_last_edit

    # update approval
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end