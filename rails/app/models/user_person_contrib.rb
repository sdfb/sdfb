class UserPersonContrib < ActiveRecord::Base
  # this class is known as "Person Notes" to the user

  include WhitespaceStripper
  include Approvable

  attr_accessible :bibliography, :created_by, :person_id, :created_at

  # Relationships
  # -----------------------------
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :created_by
  validates_presence_of :person_id
  validates_length_of   :bibliography, :minimum => 10, allow_blank: true

  # Scope
  # ----------------------------- 
  scope :for_user,         -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_person,   -> (personID) {
                                          select('user_person_contribs.*')
                                          .where('person_id = ?', personID)}

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:bibliography) }

end
