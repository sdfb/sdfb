require 'active_support/concern'

module Approvable
  extend ActiveSupport::Concern

  included do
    attr_accessible :approved_by, :approved_on, :is_approved, :is_active, :is_rejected

    validates :is_active, :inclusion => {:in => [true, false]}

    scope :all_approved,          -> { where(is_approved: true,  is_active: true, is_rejected: false) }
    scope :all_unapproved,        -> { where(is_approved: false, is_active: true, is_rejected: false) }
    scope :all_inactive,          -> { where(is_active: false) }
    scope :all_rejected,          -> { where(is_active: true, is_rejected: true)  }
    scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
    scope :approved_user,         -> (user_id){ where('approved_by = ?', "#{user_id}") }
  end
end
