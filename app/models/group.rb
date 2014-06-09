class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :name
  belongs_to :person
end
