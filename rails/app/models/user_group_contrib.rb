class UserGroupContrib < ActiveRecord::Base
  # this class is known as "Group Notes" to the user

  
  include WhitespaceStripper
  include Approvable

  attr_accessible :annotation, :bibliography, :group_id, :created_by, :created_at

  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :created_by
  validates_presence_of :group_id
  validates_presence_of :annotation
  validates_length_of   :annotation,   :minimum => 10
  validates_length_of   :bibliography, :minimum => 10, allow_blank: true

  # Scope
  # ----------------------------- 
  scope :for_user,         -> ( user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_group,    -> (groupID) {
                                        select('user_group_contribs.*')
                                        .where('group_id = ?', groupID)}

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:annotation, :bibliography)}

end
