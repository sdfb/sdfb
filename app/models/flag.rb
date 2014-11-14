class Flag < ActiveRecord::Base
  attr_accessible :assoc_object_id, :assoc_object_type, :created_by, :flag_description, :resolved_at, :resolved_by
end
