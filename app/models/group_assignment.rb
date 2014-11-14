class GroupAssignment < ActiveRecord::Base
  attr_accessible :created_by, :group_id, :is_approved, :person_id, :start_date, :end_date
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :person
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_approved, where(is_approved: true)

  # Validations
  # -----------------------------
  validates_presence_of :group_id
  validates_presence_of :person_id
  validates_presence_of :created_by

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