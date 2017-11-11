class GroupAssignment < ActiveRecord::Base

  
  include Approvable

  attr_accessible :created_by, :group_id, :person_id, :start_date, :end_date, :created_at,
    :start_year, :start_month, :start_day, :end_year, :end_month, :end_day, :bibliography,
    :start_date_type, :end_date_type
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :find_if_exists, lambda {|person_input, group_input| where('(person_id = ?) and (group_id = ?) and is_approved is true', person_input, group_input) }

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by
  validates_presence_of :start_date_type, if: 'start_year.present?'
  validates_presence_of :end_date_type, if: 'end_year.present?'
  validates_inclusion_of :start_date_type, in: SDFB::DATE_TYPES, if: 'start_year.present?'
  validates_inclusion_of :end_date_type, in: SDFB::DATE_TYPES, if: 'end_year.present?'
  validate :dates_are_possible?

  # Callbacks
  # ----------------------------- 
  before_create     :check_if_already_exists
  before_update     :check_if_duplicate
  before_validation :sanitize_dates


  # Custom Methods
  # -----------------------------

  # checks if the group and person assignment already exists and if approved
  # -----------------------------
  def check_if_already_exists
    errors.add(:person_id, "This person is already a member of this group.") if (! GroupAssignment.find_if_exists(self.person_id, self.group_id).empty?)
  end

  # -----------------------------
  def check_if_duplicate
    search_results_for_duplicate = GroupAssignment.find_if_exists(self.person_id, self.group_id)
    if ! search_results_for_duplicate.empty?
      if search_results_for_duplicate.first.id != self.id
        errors.add(:person_id, "This person is already a member of this group.")
      end
    end
  end

  # -----------------------------
  def set_start_year
    possible_dates = [person.ext_birth_year, group.start_year]
    possible_dates.map!{|year| year.present? ? year.to_i : SDFB::EARLIEST_YEAR}
    self.start_year = possible_dates.max
    self.start_date_type = "AF/IN"
  end

  # -----------------------------
  def set_end_year
    possible_dates = [person.ext_death_year, group.end_year]
    possible_dates.map!{|year| year.present? ? year.to_i : SDFB::LATEST_YEAR}
    self.end_year = possible_dates.min
    self.end_date_type = "BF/IN"
  end

  # -----------------------------
  def sanitize_dates
    set_start_year if start_year.blank?
    set_end_year if end_year.blank?
  end

  # -----------------------------
  def dates_are_possible?
    if group_record = Group.find(self.group_id)
      group_start_year = group_record.start_year.to_i
      group_end_year = group_record.end_year.to_i
    end

    if self.start_year.to_i > self.end_year.to_i
      errors.add(:start_year, "The start year must be equal to or less than the end year")
      errors.add(:end_year, "The end year must be equal to or greater than the start year")
    end

    if (self.start_year.to_i < group_start_year) || (self.start_year.to_i > group_end_year)
        errors.add(:start_year, "The start year must be between the group start year (#{group_start_year}) and group end year (#{group_end_year})")
    end

    if (self.end_year.to_i < group_start_year) || (self.end_year.to_i > group_end_year)
        errors.add(:end_year, "The end year must be between the group start year (#{group_start_year}) and group end year (#{group_end_year})")
    end
  end
end
