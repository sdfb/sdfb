class RelCatAssign < ActiveRecord::Base
  attr_accessible :relationship_category_id, :relationship_type_id, :created_at

  # Relationships
  # -----------------------------
  belongs_to :relationship_category
  belongs_to :relationship_type

  # Validations
  # -----------------------------
  validates_presence_of :relationship_category_id
  validates_presence_of :relationship_type_id

  # Scope
  # ----------------------------- 

  # Custom Methods
  # -----------------------------
end
