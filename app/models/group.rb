class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :is_approved, :name, :justification, :approved_by, :approved_on
  
  # Relationships
  # -----------------------------
  has_many :people, :through => :group_assignments
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_presence_of :description
  # validates_presence_of :created_by

  # Scope
  # ----------------------------- 
  scope :approved, where(is_approved: true)
  scope :unapproved, where(is_approved: false)

  # Custom Methods
  # -----------------------------
  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end