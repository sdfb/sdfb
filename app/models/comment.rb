class Comment < ActiveRecord::Base
  attr_accessible :associated_contrib, :comment_type, :created_by, :content
end
