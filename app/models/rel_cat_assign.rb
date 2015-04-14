class RelCatAssign < ActiveRecord::Base
  attr_accessible :relationship_category_id, :relationship_type_id, :created_at, :approved_by,
  :approved_on, :is_approved, :created_by, :is_active, :is_rejected, :edited_by_on
  serialize :edited_by_on,Array

  # Relationships
  # -----------------------------
  belongs_to :relationship_category
  belongs_to :relationship_type

  # Validations
  # -----------------------------
  validates_presence_of :relationship_category_id
  validates_presence_of :relationship_type_id
  validate :check_if_approved_valid_create, on: :create
  validate :check_if_approved_valid_update, on: :update

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :for_rel_cat, lambda {|rel_cat_id_input| where('relationship_category_id = ?', "#{rel_cat_id_input}") }
  scope :for_rel_type, lambda {|rel_type_id_input| where('relationship_type_id = ?', "#{rel_type_id_input}") }
  scope :find_if_exists, lambda {|rel_cat_id_input, rel_type_id_input| where('(relationship_category_id = ?) and (relationship_type_id = ?)', rel_cat_id_input, rel_type_id_input) }
  scope :all_inactive, where("is_active is false")
  scope :all_rejected, where("is_rejected is true")
  scope :all_recent, order('created_at DESC')
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }

  # Callbacks
  # -----------------------------
  before_create :init_array
  before_create :check_if_approved_valid_create
  before_update :check_if_approved_valid_update
  before_update :add_editor_to_edit_by_on

  # Custom Methods
  # -----------------------------
  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = RelCatAssign.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.edited_by_on)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end
  end

  def init_array
    self.edited_by_on = nil
  end

  def check_if_approved_valid_create
    errors.add(:relationship_type_id, "This relationship type already has this relationship category.") if (! RelCatAssign.find_if_exists(self.relationship_category_id, self.relationship_type_id).empty?)
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_valid_update
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end
