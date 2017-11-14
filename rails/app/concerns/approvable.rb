require 'active_support/concern'

module Approvable
  extend ActiveSupport::Concern



  included do
    attr_accessible :approved_by, :approved_on, :is_approved, :is_active

    validates :is_active, :inclusion => {:in => [true, false]}

    before_save :check_approval_status
    before_save :update_approval

    scope :all_approved,          -> { where(is_approved: true,  is_active: true) }
    scope :all_unapproved,        -> { where(is_approved: false, is_active: true) }
    scope :all_inactive,          -> { where(is_active: false) }
    scope :approved_user,         -> (user_id){ where('approved_by = ?', "#{user_id}") }
  end

  def update_approval
    if self.is_approved_changed?(from: false, to: true)
      self.approved_on = Time.now
    end
  end
  
  def check_approval_status
    unless self.is_approved
      self.approved_by = nil
      self.approved_on = nil
    end  
  end
end
