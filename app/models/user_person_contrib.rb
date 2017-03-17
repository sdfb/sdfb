class UserPersonContrib < ActiveRecord::Base
  # this class is known as "Person Notes" to the user

  include TrackLastEdit
  include WhitespaceStripper
  include Approvable

  attr_accessible :annotation, :bibliography, :created_by, :person_id, :created_at, :person_autocomplete

  # Relationships
  # -----------------------------
  belongs_to :person
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :created_by
  validates_presence_of :person_id
  validates_presence_of :annotation
  validates_length_of   :annotation, :minimum => 10
  validates_length_of   :bibliography, :minimum => 10, allow_blank: true

  # Scope
  # ----------------------------- 
  scope :for_user,         -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_person,   -> (personID) {
                                          select('user_person_contribs.*')
                                          .where('person_id = ?', personID)}
  scope :all_recent,       -> { order(updated_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Callbacks
  # ----------------------------- 
  before_save { remove_trailing_spaces(:annotation, :bibliography) }


  # Custom Methods
  # -----------------------------

  ### The two methods below are never called.  Confirm they can be removed.  -DGN 2017-3-17

  # def get_person_name
  #   return Person.find(person_id).display_name 
  # end

  # def get_users_name
  #   if (created_by != nil)
  #     return User.find(created_by).first_name + " " + User.find(created_by).last_name
  #   else
  #     return "ODNB"
  #   end
  # end
end
