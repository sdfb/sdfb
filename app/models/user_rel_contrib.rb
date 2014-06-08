class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :confidence_type, :created_by, :relationship_id, :relationship_type
end
