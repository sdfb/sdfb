class Person < ActiveRecord::Base
  attr_accessible :birth_year, :created_by, :death_year, :historical_significance, :name
end
