class GroupCatAssign < ActiveRecord::Base
  attr_accessible :group_category_id, :group_id, :created_by, :created_at

  # Relationships
  # -----------------------------
  belongs_to :user
  belongs_to :group
  belongs_to :group_category

  # Validations
  # -----------------------------
  validates_presence_of :group_category_id
  validates_presence_of :group_id
  validates_presence_of :created_by

  # Scope
  # ----------------------------- 

  # Custom Methods
  # -----------------------------
end
