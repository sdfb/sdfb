class GroupCategory < ActiveRecord::Base

  include Approvable

  attr_accessible :description, :name, :created_by, :created_at

  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :group_cat_assigns, :dependent => :destroy

  # Validations
  # -----------------------------
  validates_presence_of   :name
  validates_uniqueness_of :name
  validates_presence_of   :created_by

  # Scope
  # ----------------------------- 
  scope :for_user,         -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical,     -> { order(name: :asc) }

end