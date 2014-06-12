class Relationship < ActiveRecord::Base
  attr_accessible :average_certainty, :is_approved, :original_certainty, :person1_index, :person2_index
end
