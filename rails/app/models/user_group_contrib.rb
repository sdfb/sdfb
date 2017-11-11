class UserGroupContrib < ActiveRecord::Base
  # this class is known as "Group Notes" to the user

  include WhitespaceStripper
  include Approvable

  attr_accessible :bibliography, :group_id, :created_by, :created_at

  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :created_by
  validates_presence_of :group_id
  validates_length_of   :bibliography, :minimum => 10, allow_blank: true

  # Scope
  # ----------------------------- 
  scope :for_user,         -> ( user_input) { where('created_by = ?', "#{user_input}") }

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:bibliography)}

end
