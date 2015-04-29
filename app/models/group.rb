class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :name, :justification, :approved_by, :approved_on, 
  :created_at, :is_approved, :person_list, :start_year, :end_year, :is_active, :is_rejected,
  :start_date_type, :end_date_type, :last_edit
  serialize :person_list,Array
  serialize :last_edit,Array
  
  # Relationships
  # -----------------------------
  has_many :people, :through => :group_assignments
  has_many :group_categories, :through => :group_cat_assigns
  has_many :user_group_contribs
  belongs_to :user

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :created_by
  #validates_presence_of :approved_by
  #validates_presence_of :approved_on
  ## name must be at least 3 characters
  validates_length_of :name, :minimum => 3
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This group must be approved on or after the date it was created."
  validates :start_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :start_year_present?
  validates :start_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :start_year_present?
  validates :end_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :end_year_present?
  validates :end_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :end_year_present?
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("is_approved is true and is_active is true and is_rejected is false")
  scope :all_inactive, where("is_active is false")
  scope :all_rejected, where("is_rejected is true and is_active is true")
  scope :all_active_unrejected, where("is_active is true and is_rejected is false")
  scope :all_unapproved, where("is_approved is false and is_rejected is false and is_active is true")
  scope :all_recent, order('created_at DESC')
  scope :for_id, lambda {|id_input| where('id = ?', "#{id_input}") }
  scope :exact_name_match, lambda {|search_input| where('name like ?', "#{search_input}") }
  scope :similar_name_match, lambda {|search_input| where('name like ?', "%#{search_input}%") }
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :alphabetical, order('name')
  scope :order_by_sdfb_id, order('id')

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :check_if_approved
  before_update :check_if_approved_and_update_edit

  # Custom Methods
  # -----------------------------

  def init_array
    self.person_list = nil
    self.last_edit = nil
  end

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

  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  # searches for people by name
  def self.search_approved(search)
    if search
      return Group.all_approved.for_id(search.to_i)
    end
  end

  # searches for people by name
  def self.search_all(search)
    if search
      return Group.all.for_id(search.to_i)
    end
  end
end