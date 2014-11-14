class RelationshipType < ActiveRecord::Base
  attr_accessible :default_rel_category, :description, :is_active, :name, :relationship_type_inverse_id
end
