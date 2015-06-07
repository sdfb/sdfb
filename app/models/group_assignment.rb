class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :approved_by, :approved_on, :person_id, :start_date, :end_date, :created_at,
  :is_approved, :is_active, :is_rejected, :start_year, :start_month, :start_day, :end_year, :end_month, :end_day,
  :person_autocomplete, :start_date_type, :end_date_type, :last_edit
  serialize :last_edit,Array
  
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
  scope :all_recent, -> { order(created_at: :desc) }
  scope :all_for_person, -> (personID) {
      select('group_assignments.*')
      .where('(person_id = ?)', personID)}
  scope :all_for_group, -> (groupID) {
      select('group_assignments.*')
      .where('(group_id = ?)', groupID)}
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :find_if_exists, lambda {|person_input, group_input| where('(person_id = ?) and (group_id = ?) and is_approved is true', person_input, group_input) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by
  # checks if the group and person assignment already exists
  validate :check_if_approved_valid_create, on: :create
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?
  # validates_presence_of :approved_by
  # validates_presence_of :approved_on
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This group assignment must be approved on or after the date it was created."

  ## approved_on must occur on the same date or after the created at date

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  after_create :create_group_person_list
  after_update :create_group_person_list
  before_create :check_if_approved_valid_create
  before_update :check_if_approved_and_update_edit
  before_create :create_start_and_end_date
  before_update :create_start_and_end_date


  # Custom Methods
  # -----------------------------
  def init_array
    self.last_edit = nil
  end

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
  def check_if_approved_valid_create
    errors.add(:person_id, "This person is already a member of this group.") if (! GroupAssignment.find_if_exists(self.person_id, self.group_id).empty?)
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_and_update_edit
    new_last_edit = []
    new_last_edit.push(self.approved_by.to_i)
    new_last_edit.push(Time.now)
    self.last_edit = new_last_edit

    # update approval
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end

  ##if a user submits a new relationship but does not include a start and end date it defaults to a start and end date based on the birth years of the people in the relationship
  def create_start_and_end_date
    person_record = Person.find(self.person_id)
    if (! person_record.nil?)
      birth_year = person_record.ext_birth_year.to_i
      death_year = person_record.ext_death_year.to_i
    end
    group_record = Group.find(self.group_id)
    if (! group_record .nil?)
      group_start_year = group_record.start_year.to_i
      group_end_year = group_record.end_year.to_i
    end
    
    #Only use default start date if the user does not enter a start year
    if (self.start_year.blank?)
      #decide new assignment start date
      if ((! birth_year.blank?) || (! group_start_year.blank?))
        ##if there is a birth/group start year for at least 1 person
        new_start_year_type = "AF/IN"
        if ((! birth_year.blank?) && (! group_start_year.blank?))
          ## Use max birth/group start year because the assignment can't start before someone is born or before group started
          if ((birth_year > group_start_year) || (group_start_year.zero?) || (group_start_year.blank?) || (group_start_year.nil?))
            new_start_year = birth_year.to_i
          else
            new_start_year = group_start_year.to_i
          end
        elsif (! birth_year.blank?)
          new_start_year = birth_year.to_i
        elsif (! group_start_year.blank?)
          new_start_year = group_start_year.to_i
        end
      else
        ##if there is no group start or birth years, set start date to the default CA 1400 (around 1400)
        new_start_year_type = "CA"
        new_start_year = 1400
      end

      self.start_year = new_start_year
      self.start_date_type = new_start_year_type
    end 

    #Only use default end date if the user does not enter an end year
    if (self.end_year.blank?)
      #decide new relationship end date
      if ((! death_year.blank?) || (! group_end_year.blank?))
        ##if there is a deathdate for at least 1 person
        new_end_year_type = "BF/IN"
        if ((! death_year.blank?) && (! group_end_year.blank?))
          ## Use min deathdate if deathdates are recorded for both people because the relationship will end by the time of the people dies
          if ((death_year < group_end_year) || (group_end_year.zero?) || (group_end_year.blank?) || (group_end_year.nil?))
            new_end_year = death_year.to_i
          else
            new_end_year = group_end_year.to_i
          end
        elsif (! death_year.blank?)
          new_end_year = death_year.to_i
        elsif (! group_end_year.blank?)
          new_end_year = group_end_year.to_i
        end
      else
        ##If there is no death year, set end year to the default CA 1800 (around 1800)
        new_end_year_type = "CA"
        new_end_year = 1800
      end
      self.end_year = new_end_year
      self.end_date_type = new_end_year_type
    end
  end
end