class RelCatAssign < ActiveRecord::Base

  include TrackLastEdit
  include Approvable

  attr_accessible :relationship_category_id, :relationship_type_id, :created_at, :created_by

  # Relationships
  # -----------------------------
  belongs_to :relationship_category
  belongs_to :relationship_type
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :relationship_category_id
  validates_presence_of :relationship_type_id
  # Commented out instead of deleted. Needs further evaluation in a cleanup of the app.
  #validate :check_if_approved_valid_create, on: :create
  validate :check_if_approved_and_update_edit, on: :update

  # Scope
  # ----------------------------- 

  scope :for_rel_cat, -> (rel_cat_id_input) { where('relationship_category_id = ?', "#{rel_cat_id_input}") }
  scope :for_rel_type, -> (rel_type_id_input) { where('relationship_type_id = ?', "#{rel_type_id_input}") }
  scope :find_if_exists, -> (rel_cat_id_input, rel_type_id_input) { where('(relationship_category_id = ?) and (relationship_type_id = ?)', rel_cat_id_input, rel_type_id_input) }
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Callbacks
  # -----------------------------
  before_create :check_if_already_exists
  before_update :check_if_duplicate

  # Custom Methods
  # -----------------------------


  def check_if_already_exists
    if RelCatAssign.find_if_exists(self.relationship_category_id, self.relationship_type_id)
      errors.add(:relationship_type_id, "This relationship type is already assigned to this relationship category.")
    end
  end

  # TODO: The logic here appears backwards.  Confirm that it should be the same as above?
  def check_if_duplicate
    search_results_for_duplicate = RelCatAssign.find_if_exists(self.relationship_category_id, self.relationship_type_id)
    if search_results_for_duplicate
      if search_results_for_duplicate.first.id != self.id
        errors.add(:relationship_type_id, "This relationship type is already assigned to this relationship category.")
      end
    end
  end
end
