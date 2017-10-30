class GroupCatAssign < ActiveRecord::Base

  
  include Approvable

  attr_accessible :group_category_id, :group_id, :created_by, :created_at
  
  # Relationships
  # -----------------------------
  belongs_to :user
  belongs_to :group
  belongs_to :group_category

  # Validations
  # -----------------------------
  validates_presence_of :group_category_id
  validates_presence_of :group_id
  validates_presence_of :created_by

  # Scope
  # ----------------------------- 
  scope :all_recent,         -> { order(updated_at: :desc) }
  scope :for_group,          -> (group_id_input) { where('group_id = ?', "#{group_id_input}") }
  scope :for_group_category, -> (group_category_id_input) { where('group_category_id = ?', "#{group_category_id_input}") }
  scope :find_if_exists,     -> ( group_category_id_input, group_id_input) { where('(group_category_id = ?) and (group_id = ?)', group_category_id_input, group_id_input) }
  scope :for_user,           -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :order_by_sdfb_id,   -> { order(id: :asc) }

  # Callbacks
  # ----------------------------- 
  before_create :check_if_already_exists
  before_update :check_if_duplicate

  # Custom Methods
  # -----------------------------

  def check_if_already_exists
    if (! GroupCatAssign.find_if_exists(self.group_category_id, self.group_id).empty?)
      errors.add(:group_id, "This group already has this group category.") 
    end
  end

  def check_if_duplicate
    search_results_for_duplicate = GroupCatAssign.find_if_exists(self.group_category_id, self.group_id)
    if ! search_results_for_duplicate.empty?
      if search_results_for_duplicate.first.id != self.id
        errors.add(:group_id, "This group already has this group category.")
      end
    end
  end
  
end
