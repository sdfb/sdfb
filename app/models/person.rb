class Person < ActiveRecord::Base
  attr_accessible :birth_year, :created_by, :death_year, :first_name, :historical_significance, :last_name, :original_id
  has_many :relationships
end
