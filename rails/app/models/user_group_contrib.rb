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
  scope :all_recent,       -> { order(updated_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:annotation, :bibliography)}

  # Custom Methods
  # -----------------------------

  ### The two methods below are never called.  Confirm they can be removed.  -DGN 2017-3-17

  # def get_group_name
  #   return Group.find(group_id)
  # end

  # def get_users_name
  #   if (created_by != nil)
  #     return User.find(created_by).first_name + " " + User.find(created_by).last_name
  #   else
  #     return "ODNB"
  #   end
  # end
end
