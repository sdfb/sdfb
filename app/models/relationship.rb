class Relationship < ActiveRecord::Base
  attr_accessible :average_certainty, :created_by, :is_approved, :original_certainty, :person1_index, :person2_index
  belongs_to :user
  has_many :user_rel_contribs
end
