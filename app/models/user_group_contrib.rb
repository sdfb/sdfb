class UserGroupContrib < ActiveRecord::Base
  # this class is known as "Group Notes" to the user

  include TrackLastEdit
  include WhitespaceStripper
  
  attr_accessible :annotation, :bibliography, :group_id, :created_by, :approved_by,
  :approved_on, :created_at, :is_approved, :is_active, :is_rejected

  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :created_by
  validates_presence_of :group_id
  validates_length_of   :annotation, :minimum => 10, :if => :annot_present?
  validates_length_of   :bibliography, :minimum => 10, :if => :bib_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :for_user, -> ( user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_group, -> (groupID) {
      select('user_group_contribs.*')
      .where('group_id = ?', groupID)}
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :approved_user, -> (user_id){ where('approved_by = ?', user_id) }

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:annotation, :bibliography)}

  # Custom Methods
  # -----------------------------

  def get_group_name
    return Group.find(group_id)
  end


  def annot_present?
    !self.annotation.blank?
  end

  def bib_present?
    !self.bibliography.blank?
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
