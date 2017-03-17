class RelationshipCategory < ActiveRecord::Base

  include TrackLastEdit
  include Approvable


  attr_accessible :description, :name, :created_at, :created_by

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
  scope :all_recent,       -> { order(updated_at: :desc) }
  scope :for_user,         -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical,     -> { order(name: :asc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

end
