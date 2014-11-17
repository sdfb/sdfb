class UserGroupContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :group_id, :created_by, :edited_by_on, :reviewed_by_on, :created_at
  serialize :edited_by_on,Array
  serialize :reviewed_by_on,Array
  
  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :created_by
  validates_presence_of :group_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?


  # Scope
  # -----------------------------
  #broken since there is no is_falgged
  ##scope :not_flagged, where(is_flagged: false)

  # Custom Methods
  # -----------------------------
  def get_group_name
    return Group.find(group_id)
  end

  def annot_present?
    !annotation.nil?
  end

  def bib_present?
    !bibliography.nil?
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
