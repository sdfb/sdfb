class RelationshipType < ActiveRecord::Base

  include TrackLastEdit
  include Approvable

  attr_accessible :default_rel_category, :description, :is_active, :name, :relationship_type_inverse, 
  :created_at,  :created_by
  
  # Relationships
  # -----------------------------
  belongs_to :user
  # if a relationship type is deleted then all associated relationship category assignments are deleted
  has_many :rel_cat_assigns, :dependent => :destroy
  #belongs_to :relationship_type_inverse
  # if a relationship type is deleted then all associated relationship type assignments will have a null relationship type
  has_many :user_rel_contribs, :dependent => :nullify

  # Validations
  # -----------------------------
  #validates_presence_of :default_rel_category
  validates :is_active, :inclusion => {:in => [true, false]}
  validates_presence_of :name
  ## name must be at least 4 character
  validates_length_of :name, :minimum => 3, :if => :name_present?
  # make sure names are unique/not duplicates
  validates_uniqueness_of :name

  # Scope
  # ----------------------------- 
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical, -> { order(name: :asc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :find_where_inverse, -> (relationship_type_input) { where('relationship_type_inverse = ?', "#{relationship_type_input}") }

  # Callbacks
  # ----------------------------- 
  before_destroy :make_null_if_used_for_inverse

  # Custom Methods
  # -----------------------------


  # This record goes through all of the records where it the relationship type is used an inverse 
  # and makes that null
  def make_null_if_used_for_inverse
    # first, find all the records where the relationship type is used as an inverse in
    used_as_inverse_in = RelationshipType.find_where_inverse(self.id)
    # loop through all results and update them
    used_as_inverse_in.each do |u|
      RelationshipType.update(u.id, :relationship_type_inverse => nil)
    end
  end

  def name_present?
    !name.nil?
  end

end
