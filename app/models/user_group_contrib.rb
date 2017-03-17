class UserGroupContrib < ActiveRecord::Base
  # this class is known as "Group Notes" to the user

  include TrackLastEdit
  include WhitespaceStripper
  include Approvable

  attr_accessible :annotation, :bibliography, :group_id, :created_by, :created_at

  # Relationships
  # -----------------------------
  belongs_to :group
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :created_by
  validates_presence_of :group_id
  validates_length_of   :annotation, :minimum => 10, :if => :annot_present?
  validates_length_of   :bibliography, :minimum => 10, :if => :bib_present?

  # Scope
  # ----------------------------- 
  scope :for_user, -> ( user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_group, -> (groupID) {
      select('user_group_contribs.*')
      .where('group_id = ?', groupID)}
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:annotation, :bibliography)}

  # Custom Methods
  # -----------------------------

  def get_group_name
    return Group.find(group_id)
  end


  def annot_present?
    !self.annotation.blank?
  end

  def bib_present?
    !self.bibliography.blank?
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end
end
