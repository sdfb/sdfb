class GroupCategory < ActiveRecord::Base
  attr_accessible :description, :name, :created_by, :created_at, :is_approved

  # Relationships
  # -----------------------------
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :description
  validates_presence_of :name
  validates_presence_of :created_by

  # Scope
  # ----------------------------- 

  # Custom Methods
  # -----------------------------
end
