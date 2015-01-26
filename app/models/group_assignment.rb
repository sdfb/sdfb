class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :approved_by, :approved_on, :person_id, :start_date, :end_date, :created_at,
  :is_approved, :is_active, :is_rejected, :edited_by_on, :start_year, :start_month, :start_day, :end_year, :end_month, :end_day
  serialize :edited_by_on,Array
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :all_for_person, 
    lambda {|personID| 
      select('group_assignments.*')
      .where('(person_id = ?)', personID)}
  scope :all_for_group, 
    lambda {|groupID| 
      select('group_assignments.*')
      .where('(group_id = ?)', groupID)}
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by
  # validates_presence_of :approved_by
  # validates_presence_of :approved_on
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This group assignment must be approved on or after the date it was created."

  ## approved_on must occur on the same date or after the created at date

  # Callbacks
  # ----------------------------- 
  after_create :create_group_person_list
  after_update :create_group_person_list
  before_update :add_editor_to_edit_by_on
  before_create :check_if_approved
  before_update :check_if_approved
  before_create :init_array

  # Custom Methods
  # -----------------------------
  def init_array
    self.edited_by_on = nil
  end

  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = GroupAssignment.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.edited_by_on)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end
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
        #map by gorup name
        updated_person_groups_list = GroupAssignment.all_approved.all_for_person(self.person_id).map{|ga| Group.find(ga.group_id).name }
        Person.update(self.person_id, group_list: updated_person_groups_list)

    end
  end

  def get_person_name
    return Person.find(person_id).first_name + " " + Person.find(person_id).last_name 
  end

  def get_group_name
    return Group.find(group_id).name
  end

  def check_if_approved
    if (self.is_approved != true)
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
end