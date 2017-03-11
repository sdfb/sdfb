class RelationshipCategory < ActiveRecord::Base

  include TrackLastEdit

  attr_accessible :description, :name, :created_at, :is_approved, :created_by, :approved_by, :approved_on,
  :is_active, :is_rejected

  # Relationships
  # -----------------------------
  # if the relationship category is deleted then all associated relationship category assignments are deleted
  has_many :rel_cat_assigns, dependent: :destroy
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_uniqueness_of :name

  # Scope
  # ----------------------------- 
  scope :all_approved,     -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive,     -> { where(is_active: false) }
  scope :all_rejected,     -> { where(is_rejected: true, is_active: true) }
  scope :all_unapproved,   -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :all_recent,       -> { order(updated_at: :desc) }
  scope :for_user,         -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical,     -> { order(name: :asc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }

end
