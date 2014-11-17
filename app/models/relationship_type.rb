class RelationshipType < ActiveRecord::Base
  attr_accessible :default_rel_category, :description, :is_active, :name, :relationship_type_inverse_id, :created_at

  # Relationships
  # -----------------------------
  has_many :relationships, through :rel_cat_assigns

  # Validations
  # -----------------------------
  validates_presence_of :default_rel_category
  validates_presence_of :is_active
  validates_presence_of :name
  validates_presence_of :relationship_type_inverse_id
  ## name must be at least 4 character
  validates_length_of :name, :minimum => 4, :if => :name_present?

  # Scope
  # ----------------------------- 

  # Custom Methods
  # -----------------------------

  def name_present?
    !name.nil?
  end

end
