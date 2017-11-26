class Group < ActiveRecord::Base

  include Approvable

  attr_accessible  :description, :name, :justification, :citation,
                   :start_year, :end_year, :start_date_type, :end_date_type,
                   :created_by, :created_at
  
  # Relationships
  # -----------------------------
  has_many :people, through: :group_assignments
  has_many :group_assignments,   dependent: :destroy
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of  :name
  validates_presence_of  :description
  validates_presence_of  :created_by
  validates_length_of    :name, :minimum => 3
  validates_inclusion_of :start_date_type, :in => SDFB::DATE_TYPES, :if => "self.start_year.present?"
  validates_inclusion_of :end_date_type,   :in => SDFB::DATE_TYPES, :if => "self.end_year.present?"

  # Scope
  # ----------------------------- 
  scope :for_user,              -> (user_input) { where('created_by = ?', "#{user_input}") }
  
  # Callbacks
  # ----------------------------- 
  before_save   :create_check_start_and_end_date

  # Custom Methods
  # -----------------------------
  def approved_people
    people = self.group_assignments.where('group_assignments.is_approved = ?', true).map{|ga| ga.person_id}
    Person.all_approved.where(id: people)
  end

  # checks that end year is on or after start year and that start 
  # and end years meet SDFB::EARLIEST_YEAR and SDFB::LATEST_YEAR rules
  def create_check_start_and_end_date

    # add a start date type if there is none
    if (start_date_type.blank?)
      self.start_date_type = "IN"
    end

    # add an end date type if there is none
    if (end_date_type.blank?)
      self.end_date_type = "IN"
    end

    # add a start year if there isn't one, check if follows rules
    if (start_year.blank?)
      self.start_year = SDFB::EARLIEST_YEAR
      self.start_date_type = "CA"
    # if there is already a start year, check that start year is before SDFB::LATEST_YEAR or throw error
    elsif (self.start_year.to_i > SDFB::LATEST_YEAR)
      errors.add(:start_year, "The start year must be on or before #{SDFB::LATEST_YEAR}")
    end

    # add an end year if there isn't one, check if follows rules
    if (end_year.blank?)
      self.end_year = SDFB::LATEST_YEAR
      self.end_date_type = "CA"
    # if there is already a end year, check that end year is after SDFB::EARLIEST_YEAR or throw error
    elsif (self.end_year.to_i < SDFB::EARLIEST_YEAR)
      errors.add(:end_year, "The end year must be on or after #{SDFB::EARLIEST_YEAR}")
    end

    # if the start year converted to an integer is 0 then the date was not an integer
    if (self.start_year.to_i == 0)
      errors.add(:start_year, "Please enter a valid start year.")
    end

    # if the end year converted to an integer is 0 then the date was not an integer
    if (self.end_year.to_i == 0)
      errors.add(:end_year, "Please enter a valid end year.")
    end

    # check that start year is equal to or before end year
    if (self.start_year.to_i > self.end_year.to_i)
      errors.add(:start_year, "The start year must be less than or equal to the end year")
      errors.add(:end_year, "The end year must be greater than or equal to the start year")
    end
  end
end