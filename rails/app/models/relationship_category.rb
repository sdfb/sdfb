class RelationshipCategory < ActiveRecord::Base

  
  include Approvable

  attr_accessible :description, :name, :created_at, :created_by

  # Relationships
  # -----------------------------
  has_many :rel_cat_assigns, dependent: :destroy
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of   :name
  validates_uniqueness_of :name

  # Scope
  # ----------------------------- 
  scope :for_user,         -> (user_input) { where('created_by = ?', "#{user_input}") }

end
