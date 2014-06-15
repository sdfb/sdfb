class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence_type, :created_by, :is_flagged, :relationship_id, :relationship_type
  belongs_to :relationship
  belongs_to :user
end
