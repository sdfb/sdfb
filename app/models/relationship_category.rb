class RelationshipCategory < ActiveRecord::Base
  attr_accessible :description, :name, :created_at, :is_approved

  # Relationships
  # -----------------------------
  has_many :relationships, :through => :rel_cat_assigns

  # Validations
  # -----------------------------
  validates_presence_of :name

  # Scope
  # ----------------------------- 

  # Custom Methods
  # -----------------------------
end
