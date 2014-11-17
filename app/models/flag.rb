class Flag < ActiveRecord::Base
  attr_accessible :assoc_object_id, :assoc_object_type, :created_by, :flag_description, :resolved_at, :resolved_by, :created_at
  
  # Relationships
  # -----------------------------
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :assoc_object_id
  validates_presence_of :assoc_object_type
  validates_presence_of :created_by
  validates_presence_of :flag_description
  validates_presence_of :resolved_at
  validates_presence_of :resolved_by
  ## flag_description must be at least 10 characters
  validates_length_of :flag_description, :minimum => 10, :if => :flag_descrip_present?

  # Scope
  # ----------------------------- 


  # Custom Methods
  # -----------------------------
  def flag_descrip_present?
    !flag_description.nil?
  end

end
