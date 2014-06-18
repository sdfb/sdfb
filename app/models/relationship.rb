class Relationship < ActiveRecord::Base
  attr_accessible :average_certainty, :created_by, :is_approved, :original_certainty, :person1_index, :person2_index
  
  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :user_rel_contribs

	# Validations
	# -----------------------------
	# Validates that a person cannot have a relationship with themselves
 	validate :check_two_different_people
  validates_presence_of :person1_index
  validates_presence_of :person2_index
  validates_presence_of :average_certainty
  validates_presence_of :original_certainty
  validates_presence_of :is_approved
  # validates_presence_of :created_by

	# Custom Methods
	# -----------------------------
 	# Validation method to check that one person is not in a relationship with themselves
  def check_two_different_people
    errors.add(:person2_index, "A person cannot have a relationship with his or herself.") if person1_index == person2_index
  end
end
