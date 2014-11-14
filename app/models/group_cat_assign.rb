class GroupCatAssign < ActiveRecord::Base
  attr_accessible :group_category_id, :group_id, :created_by
end

//write created_by
//only admin and curators can do this
