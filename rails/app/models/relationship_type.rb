class RelationshipType < ActiveRecord::Base

  
  include Approvable

  attr_accessible :description, :name, :relationship_type_inverse, :created_at, :created_by,
    :default_rel_category # default_rel_category is never used and should be removed from the table.
  
  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :rel_cat_assigns, :dependent => :destroy
  has_many :user_rel_contribs, :dependent => :nullify

  # Validations
  # -----------------------------
  validates_presence_of   :name
  validates_length_of     :name, :minimum => 3
  validates_uniqueness_of :name

  # Scope
  # ----------------------------- 
  scope :all_recent,         -> { order(updated_at: :desc) }
  scope :for_user,           -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical,       -> { order(name: :asc) }
  scope :order_by_sdfb_id,   -> { order(id: :asc) }
  scope :find_where_inverse, -> (relationship_type_input) { where('relationship_type_inverse = ?', "#{relationship_type_input}") }

  # Callbacks
  # ----------------------------- 
  before_destroy :make_null_if_used_for_inverse

  # Custom Methods
  # -----------------------------

  # This record goes through all of the records where  
  # the relationship type is used as an inverse and makes that inverse null.
  def make_null_if_used_for_inverse
    # first, find all the records where the relationship type is used as an inverse in
    used_as_inverse_in = RelationshipType.find_where_inverse(self.id)
    # loop through all results and update them
    used_as_inverse_in.each do |u|
      RelationshipType.update(u.id, :relationship_type_inverse => nil)
    end
  end

end
