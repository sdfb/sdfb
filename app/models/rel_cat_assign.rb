class RelCatAssign < ActiveRecord::Base
  attr_accessible :relationship_category_id, :relationship_type_id, :created_at, :approved_by,
  :approved_on, :is_approved, :created_by

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
  scope :all_approved, where("approved_by is not null")
  scope :all_unapproved, where("approved_by is null")
  scope :for_rel_cat, lambda {|rel_cat_id_input| where('relationship_category_id = ?', "#{rel_cat_id_input}") }
  scope :for_rel_type, lambda {|rel_type_id_input| where('relationship_type_id = ?', "#{rel_type_id_input}") }

  # Custom Methods
  # -----------------------------
end
