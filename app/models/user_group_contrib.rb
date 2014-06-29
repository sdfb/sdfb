class UserGroupContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :group_id, :is_flagged
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :bibliography
  validates_presence_of :created_by
  validates_presence_of :group_id
  # validates_presence_of :is_flagged
  validates_uniqueness_of :email

  # Scope
  # -----------------------------
  scope :not_flagged, where(is_flagged: false)

  # Custom Methods
  # -----------------------------
  def get_group_name
    return Group.find(group_id)
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
