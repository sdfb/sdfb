class UserPersonContrib < ActiveRecord::Base
  # this class is known as "Person Notes" to the user

  include TrackLastEdit
  include WhitespaceStripper

  attr_accessible :annotation, :bibliography, :created_by, :person_id, :approved_by,
  :approved_on, :created_at, :is_approved, :is_active, :is_rejected, :person_autocomplete

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
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_person, -> (personID) {
      select('user_person_contribs.*')
      .where('person_id = ?', personID)}
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :approved_user, -> (user_id){ where('approved_by = ?', user_id) }

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:annotation, :bibliography)}


  # Custom Methods
  # -----------------------------

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
