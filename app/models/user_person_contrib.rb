class UserPersonContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :is_flagged, :person_id
end
