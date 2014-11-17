class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :approved_by, :approved_on, :person_id, :start_date, :end_date, :created_at
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by
  validates_presence_of :approved_by
  validates_presence_of :approved_on
  ## approved_on must occur on the same date or after the created at date
  validates_date :approved_on, :on_or_after => :created_at, :message => "This group assignment must be approved on or after the date it was created."

  ## approved_on must occur on the same date or after the created at date
  validates_date :end_date, :on_or_after => :start_date, :message => "End date must be on or after the start date."

  # Custom Methods
  # -----------------------------
  def get_person_name
    return Person.find(person_id).first_name + " " + Person.find(person_id).last_name 
  end

  def get_group_name
    return Group.find(group_id).name
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end