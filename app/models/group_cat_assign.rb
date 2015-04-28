class GroupCatAssign < ActiveRecord::Base
  attr_accessible :group_category_id, :group_id, :created_by, :created_at, :approved_by, :approved_on, :is_approved,
  :is_active, :is_rejected, :last_edit
  serialize :last_edit,Array

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
  validate :check_if_approved_valid_create, on: :create


  # Scope
  # ----------------------------- 
  scope :all_approved, where("is_approved is true and is_active is true and is_rejected is false")
  scope :all_inactive, where("is_active is false")
  scope :all_rejected, where("is_rejected is true and is_active is true")
  scope :all_unapproved, where("is_approved is false and is_rejected is false and is_active is true")
  scope :all_recent, order('created_at DESC')
  scope :for_group, lambda {|group_id_input| where('group_id = ?', "#{group_id_input}") }
  scope :for_group_category, lambda {|group_category_id_input| where('group_category_id = ?', "#{group_category_id_input}") }
  scope :find_if_exists, lambda {|group_category_id_input, group_id_input| where('(group_category_id = ?) and (group_id = ?)', group_category_id_input, group_id_input) }
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :order_by_sdfb_id, order('id')

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :check_if_approved_valid_create
  before_update :check_if_approved_and_update_edit


  # Custom Methods
  # -----------------------------
  def init_array
    self.last_edit = nil
  end

  def check_if_approved_valid_create
      errors.add(:group_id, "This group already has this group category.") if (! GroupCatAssign.find_if_exists(self.group_category_id, self.group_id).empty?)
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