class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence_type, :created_by, :relationship_id, :relationship_type
  belongs_to :user
  belongs_to :relationship
end
