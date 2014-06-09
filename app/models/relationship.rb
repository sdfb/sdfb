class Relationship < ActiveRecord::Base
  attr_accessible :original_certainty, :person1_index, :person2_index
	has_many :user_rel_contribs
	belongs_to :person

	# Validations
 	# -----------------------------
 	# Validates that a person cannot have a relationship with themselves
 	# validate :check_two_different_people

 	# Validation method to check that one person is not in a relationship with themselves
  # def check_two_different_people
  #   errors.add(:person2_index, "A person cannot have a relationship with hisself") if person1_index == person2_index
  # end
end
