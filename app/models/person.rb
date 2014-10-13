class Person < ActiveRecord::Base
  attr_accessible :birth_year, :created_by, :death_year, :first_name, :historical_significance, :is_approved, :last_name, :original_id, :rel_sum
  serialize :rel_sum,Array
  #rel_sum is the relationship summary that is updated whenever a relationship is created or updated
  #rel_sum includes the person the indvidual has a relationship with, the updated average certainty, and whether it has been approved

  # Relationships
  # -----------------------------
  has_many :groups, :through => :group_assignments
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_approved, where(is_approved: true)
  scope :for_original_id, lambda {|original_id_input| where('original_id like ?', "%#{original_id_input}%") }
  scope :for_first_name, lambda {|first_name_input| where('first_name like ?', "%#{first_name_input}")}
  scope :for_last_name, lambda {|last_name_input| where('last_name like ?', "%#{last_name_input}")}
  scope :for_first_or_last_name,  lambda {|name_input| find_by_sql("SELECT * FROM people
  where first_name like '#{name_input}' OR last_name like '#{name_input}'")}

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

  # searches for people by name
  def self.search(search)
    if search  
      return for_first_or_last_name(search)
    end
  end
end


