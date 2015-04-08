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
  validate :check_if_approved_valid_create, on: :create
  validate :check_if_approved_valid_update, on: :update


  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_inactive, where("is_active is false")
  scope :all_rejected, where("is_rejected is true")
  scope :all_recent, order('created_at DESC')
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :for_group, lambda {|group_id_input| where('group_id = ?', "#{group_id_input}") }
  scope :for_group_category, lambda {|group_category_id_input| where('group_category_id = ?', "#{group_category_id_input}") }
  scope :find_if_exists, lambda {|group_category_id_input, group_id_input| where('(group_category_id = ?) and (group_id = ?)', group_category_id_input, group_id_input) }

  # Callbacks
  # ----------------------------- 
  before_create :check_if_approved_valid_create
  before_update :check_if_approved_valid_update
  before_create :init_array
  before_update :add_editor_to_edit_by_on

  # Custom Methods
  # -----------------------------
  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = GroupCatAssign.find(self.id).edited_by_on
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
  
  def check_if_approved_valid_create
      errors.add(:group_id, "This group already has this group category.") if (! GroupCatAssign.find_if_exists(self.group_category_id, self.group_id).empty?)
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_valid_update
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end