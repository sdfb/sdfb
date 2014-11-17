class Person < ActiveRecord::Base
  attr_accessible :odnb_id, :first_name, :last_name, :created_by, :historical_significance, :uncertain, :unlikely, :possible,
  :likely, :certain, :rel_sum, :prefix, :suffix, :search_names_all, :title, :birth_year_type, :ext_birth_year, :alt_birth_year, :death_year_type,
  :ext_death_year, :alt_death_year, :justification, :approved_by, :approved_on, :created_at
  serialize :rel_sum,Array
  #rel_sum is the relationship summary that is updated whenever a relationship is created or updated
  #rel_sum includes the person the indvidual has a relationship with, the updated average certainty, and whether it has been approved

  # Relationships
  # -----------------------------
  has_many :groups, :through => :group_assignments
  has_many :user_person_contribs
  belongs_to :user

  # Scope
  # ----------------------------- 
  ####scope :all_approved, where(is_approved: true)
  scope :for_original_id, lambda {|original_id_input| where('original_id like ?', "%#{original_id_input}%") }
  scope :for_first_name, lambda {|first_name_input| where('first_name like ?', "%#{first_name_input}")}
  scope :for_last_name, lambda {|last_name_input| where('last_name like ?', "%#{last_name_input}")}
  scope :for_first_or_last_name,  lambda {|name_input| find_by_sql("SELECT * FROM people
  where first_name like '#{name_input}' OR last_name like '#{name_input}'")}
  
  # Validations
  # -----------------------------
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :created_by
  validates_presence_of :uncertain
  validates_presence_of :unlikely
  validates_presence_of :possible
  validates_presence_of :likely
  validates_presence_of :certain
  validates_presence_of :rel_sum
  validates_presence_of :birth_year_type
  validates_presence_of :ext_birth_year
  validates_presence_of :death_year_type
  validates_presence_of :ext_death_year
  validates_presence_of :alt_death_year
  validates_presence_of :approved_by
  validates_presence_of :approved_on
  ## first_name must be at least 1 character
  validates_length_of :first_name, :minimum => 1, :if => :first_name_present?
  ## last_name must be at least 1 character
  validates_length_of :last_name, :minimum => 1, :if => :last_name_present?
  ## historical_significance must be at least 4 characters
  validates_length_of :historical_significance, :minimum => 4, :if => :hist_sig_present?
  ## prefix must be at least 2 characters
  validates_length_of :prefix, :minimum => 2, :if => :prefix_present?
  ## suffix must be at least 1 character
  validates_length_of :suffix, :minimum => 1, :if => :suffix_present?
  ## title must be at least 4 characters
  validates_length_of :title, :minimum => 4, :if => :title_present?
  ## justification must be at least 4 characters
  validates_length_of :justification, :minimum => 4, :if => :just_present?
  ## approved_on must occur on the same date or after the created at date
  validates_date :approved_on, :on_or_after => :created_at, :message => "This person must be approved on or after the date it was created."
  ## birth year type is one included in the list
  validates :birth_year_type, inclusion => {:in => DATE_TYPE_LIST}
  ## birth year type is one included in the list
  validates :death_year_type, inclusion => {:in => DATE_TYPE_LIST}


  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA"]

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

  def first_name_present?
    !first_name.nil?
  end

  def last_name_present?
    !last_name.nil?
  end

  def hist_sig_present?
    !historical_significance.nil?
  end

  def prefix_present?
    !prefix_present.nil?
  end

  def suffix_present?
    !suffix.nil?
  end

  def title_present?
    !title.nil?
  end

  def just_present?
    !justification.nil?
  end
end

