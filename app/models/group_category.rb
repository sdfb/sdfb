class GroupCategory < ActiveRecord::Base

  include TrackLastEdit
  include Approvable


  attr_accessible :description, :name, :created_by, :created_at

  # Relationships
  # -----------------------------
  belongs_to :user
  # if the group category is deleted then all associated group category assignments are deleted
  has_many :group_cat_assigns, :dependent => :destroy

  # Validations
  # -----------------------------
  #validates_presence_of :description
  validates_presence_of :name
  validates_presence_of :created_by
  # make sure names are unique/not duplicates
  validates_uniqueness_of :name

  # Scope
  # ----------------------------- 
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical, -> { order(name: :asc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

end