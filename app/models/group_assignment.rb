class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :approved_by, :approved_on, :person_id, :start_date, :end_date, :created_at,
  :is_approved, :is_active, :is_rejected, :edited_by_on
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
  validates_date :end_date, :on_or_after => :start_date, :message => "End date must be on or after the start date."

  # Callbacks
  # ----------------------------- 
  after_create :create_group_person_list
  after_update :update_group_person_list
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
      current_group_person_list = Group.find(self.group_id).person_list
      person = Person.find(self.person_id)
      person_record_input = person.get_person_name + " (" + person.id.to_s + ")" 
      current_group_person_list.push(person_record_input)
      Group.update(self.group_id, person_list: current_group_person_list)

      #adds the group to the person
      current_person_groups_list = Person.find(self.person_id).group_list
      group = Group.find(self.group_id)
      current_person_groups_list.push(group.name)
      Person.update(self.person_id, group_list: current_person_groups_list)
    end
  end

  def update_group_person_list
    current_group_person_list = Group.find(self.group_id).person_list
    person = Person.find(self.person_id)
    person_record_input = person.get_person_name + " (" + person.id.to_s + ")"
    already_in_list = false
    current_person_groups_list = Person.find(self.person_id).group_list
    group = Group.find(self.group_id)
    group_input = group.name

    if (self.is_approved == true)
      #if approved, checks that the person's name is in the Group, this also indicates whether the group names are in
      #the person's group list
      current_group_person_list.each do |person_record|
        if (person_record == person_record_input)
          already_in_list = true
        end
      end

      #if the person's name is not in the Group, then add it
      if (already_in_list == false) 
        current_group_person_list.push(person_record_input)
        Group.update(self.group_id, person_list: current_group_person_list)

        #adds the group to the person
        current_person_groups_list.push(group_input)
        Person.update(self.person_id, group_list: current_person_groups_list)
      end    
    else
      # if it is not approved, check if the person's name is in the group
      current_group_person_list.each_with_index do |person_record, i|
        if (person_record == person_record_input)
          #if the person's name is already in the group, then delete it

          current_group_person_list.delete_at(i)
          Group.update(self.group_id, person_list: current_group_person_list)
          break
        end
      end
      current_person_groups_list.each_with_index do |group_record, i|
        if (group_record == group_input)
          current_person_groups_list.delete_at(i)
          Person.update(self.person_id, group_list: current_person_groups_list)
        end
      end
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