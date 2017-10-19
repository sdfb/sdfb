class GroupAssignment < ActiveRecord::Base

  include TrackLastEdit
  include Approvable

  attr_accessible :created_by, :group_id, :person_id, :start_date, :end_date, :created_at,
   :start_year, :start_month, :start_day, :end_year, :end_month, :end_day, :annotation, :bibliography,
  :person_autocomplete, :start_date_type, :end_date_type
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :all_for_person, -> (personID) {
      select('group_assignments.*')
      .where('(person_id = ?)', personID)}
  scope :all_for_group, -> (groupID) {
      select('group_assignments.*')
      .where('(group_id = ?)', groupID)}
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :find_if_exists, lambda {|person_input, group_input| where('(person_id = ?) and (group_id = ?) and is_approved is true', person_input, group_input) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

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
  after_save        :create_group_person_list
  after_destroy     :create_group_person_list

  # Custom Methods
  # -----------------------------

  def create_group_person_list
    if (self.is_approved == true)
      #adds the person's id to the Group
        #find all approved group_assignments for that group
        #map by first name last name (birth year)
        updated_group_person_list = GroupAssignment.all_approved.all_for_group(self.group_id).map do |ga| 
          str  = Person.find(ga.person_id).first_name + " " 
          str += Person.find(ga.person_id).last_name 
          str += " (" + Person.find(ga.person_id).ext_birth_year + ")"
        end
        Group.update(self.group_id, person_list: updated_group_person_list)

      #adds the group to the person
        #find all approved group_assignments for that person
        #map by group name
        updated_person_groups_list = GroupAssignment.all_approved.all_for_person(self.person_id).map{|ga| Group.find(ga.group_id).name }
        Person.update(self.person_id, group_list: updated_person_groups_list)
    end
  end

  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  def get_person_name
    return Person.find(person_id).display_name 
  end

  def get_group_name
    return Group.find(group_id).name
  end

  # checks if the group and person assignment already exists and if approved
  def check_if_already_exists
    errors.add(:person_id, "This person is already a member of this group.") if (! GroupAssignment.find_if_exists(self.person_id, self.group_id).empty?)
  end

  def check_if_duplicate
    search_results_for_duplicate = GroupAssignment.find_if_exists(self.person_id, self.group_id)
    if ! search_results_for_duplicate.empty?
      if search_results_for_duplicate.first.id != self.id
        errors.add(:person_id, "This person is already a member of this group.")
      end
    end
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end

  def set_start_year
    possible_dates = [person.ext_birth_year, group.start_year]
    possible_dates.map!{|year| year.present? ? year.to_i : SDFB::EARLIEST_YEAR}
    self.start_year = possible_dates.max
    self.start_date_type = "AF/IN"
  end

  def set_end_year
    possible_dates = [person.ext_death_year, group.end_year]
    possible_dates.map!{|year| year.present? ? year.to_i : SDFB::LATEST_YEAR}
    self.end_year = possible_dates.min
    self.end_date_type = "BF/IN"
  end

  def sanitize_dates
    set_start_year if start_year.blank?
    set_end_year if end_year.blank?
  end

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
