class RelationshipType < ActiveRecord::Base
  attr_accessible :default_rel_category, :description, :is_active, :name, :relationship_type_inverse, 
  :created_at, :is_approved, :approved_by, :approved_on, :created_by, :is_active, :is_rejected, :last_edit
  serialize :last_edit,Array
  
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
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :all_recent, -> { order(created_at: :desc) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical, -> { order(name: :asc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }

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

  def name_present?
    !name.nil?
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
