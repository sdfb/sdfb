class Person < ActiveRecord::Base
  attr_accessible :birth_year, :created_by, :death_year, :first_name, :historical_significance, :is_approved, :last_name, :original_id
  
  # Relationships
  # -----------------------------
  has_many :groups, :through => :group_assignments
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_approved, where(is_approved: true)
  scope :for_original_id, lambda {|original_id_input| where('original_id like ?', "%#{original_id_input}%") }

  # Validations
  # -----------------------------
  validates_presence_of :birth_year
  # validates_presence_of :created_by
  validates_presence_of :death_year
  validates_presence_of :first_name
  validates_presence_of :historical_significance
  validates_presence_of :last_name
  validates_presence_of :original_id

  # Custom Methods
  # -----------------------------
  def get_person_name
    return first_name + " " + last_name 
  end
end

