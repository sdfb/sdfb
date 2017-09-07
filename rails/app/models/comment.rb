class Comment < ActiveRecord::Base
  attr_accessible :associated_contrib, :comment_type, :created_by, :content, :created_at

  # Relationships
  # -----------------------------
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :associated_contrib
  validates_presence_of :comment_type
  validates_presence_of :created_by
  validates_presence_of :content
  ## content must be at least 10 characters
  validates_length_of :content, :minimum => 10, :if => :content_present?

  # Scope
  # ----------------------------- 

  # Custom Methods
  # -----------------------------
  def content_present?
    !content.nil?
  end


end
