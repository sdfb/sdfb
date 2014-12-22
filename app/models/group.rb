class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :name, :justification, :approved_by, :approved_on, 
  :created_at, :is_approved
  
  # Relationships
  # -----------------------------
  has_many :people, :through => :group_assignments
  has_many :group_categories, :through => :group_cat_assigns
  has_many :user_group_contribs
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :created_by
  #validates_presence_of :approved_by
  #validates_presence_of :approved_on
  ## name must be at least 3 characters
  validates_length_of :name, :minimum => 3, :if => :name_present?
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This group must be approved on or after the date it was created."

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_unapproved, where("approved_by is null")
  before_create :check_if_approved
  before_update :check_if_approved

  # Custom Methods
  # -----------------------------
  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end

  def check_if_approved
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def name_present?
    !name.nil?
  end
end