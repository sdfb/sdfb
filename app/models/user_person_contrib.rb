class UserPersonContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :person_id, :approved_by,
  :approved_on, :created_at, :is_approved, :is_active, :is_rejected, :person_autocomplete, :last_edit
  serialize :last_edit,Array

  # Relationships
  # -----------------------------
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :created_by
  validates_presence_of :person_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :all_for_person, lambda {|personID| 
      select('user_person_contribs.*')
      .where('person_id = ?', personID)}
  scope :all_recent, -> { order(created_at: :desc) }
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

  def annot_present?
    !annotation.blank?
  end

  def bib_present?
    !bibliography.blank?
  end

  def get_person_name
    return Person.find(person_id).display_name 
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
