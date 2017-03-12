class GroupAssignment < ActiveRecord::Base

  include TrackLastEdit

  attr_accessible :created_by, :group_id, :approved_by, :approved_on, :person_id, :start_date, :end_date, :created_at,
  :is_approved, :is_active, :is_rejected, :start_year, :start_month, :start_day, :end_year, :end_month, :end_day,
  :person_autocomplete, :start_date_type, :end_date_type
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected:false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
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
  scope :approved_user, -> (user_id){ where('approved_by = ?', "#{user_id}") }

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by
  # checks if the group and person assignment already exists on create
  validate :check_if_approved_valid_create, on: :create
  # checks if the group and person assignment already exists on update
  validate :check_if_approved_and_update_edit, on: :update
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => SDFB::DATE_TYPES, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => SDFB::DATE_TYPES, :if => :end_year_present?
  # custom validation that checks that start year is between or equal to 1500 and 1700 unless the people's birth years are outside of the date range
  validate :create_check_start_and_end_date


  # Callbacks
  # ----------------------------- 
  before_create :check_if_already_exists
  before_update :check_if_duplicate
  before_save   :create_check_start_and_end_date
  after_save    :create_group_person_list
  after_destroy :create_group_person_list


  # Custom Methods
  # -----------------------------

  def create_group_person_list
    if (self.is_approved == true)
      #adds the person's id to the Group
        #find all approved group_assignments for that group
        #map by first name last name (birth year)
        updated_group_person_list = GroupAssignment.all_approved.all_for_group(self.group_id).map{|ga| Person.find(ga.person_id).first_name + " " + Person.find(ga.person_id).last_name + " (" + Person.find(ga.person_id).ext_birth_year + ")"}
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

  ## if there are no dates entered, use the group start and end dates
  ## We do not use the person's birth and death dates because the group may be established before that person exists or after the person dies
  ## if dates are entered, check that they fit within the start and end dates
  ## use the min year and max year as a last resort if there are no group start and end dates

  def create_check_start_and_end_date
    
    # get the group start and end dates
    group_record = Group.find(self.group_id)
    if (! group_record.nil?)
      group_start_year = group_record.start_year.to_i
      group_end_year = group_record.end_year.to_i
    end
    
    # track whether default dates are used. If they are, then some checks on the dates don't
    # have to happen
    group_start_year_used = false
    group_end_year_used = false
    default_start_year_used = false
    default_end_year_used = false

    #Only use default start date if the user does not enter a start year
    if (self.start_year.blank?)
      # if there is a group start year use it
      if (! group_start_year.blank?)
        new_start_year = group_start_year.to_i
        group_start_year_used = true  
      # if there is no group start year use the default
      else
        ##if there is no group start year, set start date to circa min year
        new_start_year = SDFB::EARLIEST_YEAR
        default_start_year_used = true 
      end
      #change the record in the database to reflect default
      self.start_year = new_start_year
      self.start_date_type = "AF/IN"
        
    end
    # the same check needs to be done on the end year to make sure that it ends before the people die or the group ends
    if (self.end_year.blank?)
      # if a group end year exists, use that
      if (! group_end_year.blank?)
        new_end_year = group_end_year.to_i
        group_end_year_used = true  
      else
        ##if there is no group end year, set end to circa max year
        new_end_year = SDFB::LATEST_YEAR
        default_end_year_used = true 
      end
      #change the record in the database to reflect default
      self.end_year = new_end_year
      self.end_date_type = "BF/IN"
    end

    # first check that end year is after start year
    if self.start_year.to_i > self.end_year.to_i
      errors.add(:start_year, "The start year must be equal to or less than the end year")
      errors.add(:end_year, "The end year must be equal to or greater than the start year")
      if group_start_year_used == true
        errors.add(:start_year, "Manually adjust this default start year which is based on the group's start year (#{group_start_year})")
      elsif default_start_year_used == true
        errors.add(:start_year, "Manually adjust this default start year which is based on the SDFB minimum year of #{SDFB::EARLIEST_YEAR}")
      end
      if group_end_year_used == true
        errors.add(:end_year, "Manually adjust this default end year which is based on the group's end years (#{group_end_year})")
      elsif default_end_year_used == true
        errors.add(:end_year, "Manually adjust this default end year which is based on the SDFB maximum year of #{SDFB::LATEST_YEAR}")
      end
    end
   
    # need to run additional checks to make sure that dates are the group dates unless both are defaults
    if ((default_start_year_used == false) || (default_end_year_used == false))
      # throw an error if the start year is before the group start year or after the group end year

      if (self.start_year.to_i < group_start_year) || (self.start_year.to_i > group_end_year) 
          errors.add(:start_year, "The start year must be between the group start year (#{group_start_year}) and group end year (#{group_end_year})")
      end

      if (self.end_year.to_i < group_start_year) || (self.end_year.to_i > group_end_year)     
          errors.add(:end_year, "The end year must be between the group start year (#{group_start_year}) and group end year (#{group_end_year})")
      end
    end
  end
end