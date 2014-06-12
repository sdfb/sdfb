class UserGroupContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :created_by, :group_id, :is_flagged
end
