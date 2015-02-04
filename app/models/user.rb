class User < ActiveRecord::Base
  attr_accessible :about_description, :affiliation, :email, :first_name, :is_active, :last_name, :password,
  :password_confirmation, :user_type, :password_hash, :password_salt, :prefix, :orcid, :curator_revoked, :username, :created_at
  attr_accessor :password

  # Callbacks
  # -----------------------------
  before_save :encrypt_password

  # Relationships
  # -----------------------------
  has_many :comments
  has_many :flags
  has_many :user_group_contribs
  has_many :user_person_contribs
  has_many :user_rel_contribs
  has_many :people
  has_many :relationships
  has_many :groups
  has_many :group_assignments
  has_many :group_cat_assigns
  has_many :group_categories
  

  # Misc Constants
  # -----------------------------
  USER_TYPES_LIST = ["Standard", "Curator","Admin"]

  # Validations
  # -----------------------------
  validates_presence_of :first_name
  validates :is_active, :inclusion => {:in => [true, false]}
  validates_presence_of :last_name
  validates_presence_of :password_confirmation, :on => :create
  validates_presence_of :user_type
  validates :curator_revoked, :inclusion => {:in => [true, false]}
  validates_presence_of :username
  validates_uniqueness_of :username
  # username must be at least 6 characters long
  validates_length_of :username, :minimum => 6, :if => :username_present?
  ## first_name must be at least 1 character
  validates_length_of :first_name, :minimum => 1, :if => :first_name_present?
  ## last_name must be at least 1 character
  validates_length_of :last_name, :minimum => 1, :if => :last_name_present?
  # password must be present and at least 4 characters long, with a confirmation
  validates_presence_of :password, :on => :create

  #user must be one of three types: standard, curator, admin
  validates :user_type, :inclusion => {:in => USER_TYPES_LIST}

  # email must be present and be a valid email format
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :message => "Your username should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[\w]([^@\s,;]+)@(([a-z0-9.-]+\.)+(com|edu|org|net|gov|mil|biz|info))$/i
  # password must have one number, one letter, and be at least 6 characters
  validates_format_of :password, :with =>  /^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){6,}$/, :message => "Your password must include at least one number, at least one letter, and at least 7 characters.", :if => :password_present?
  validates :password, confirmation: true, :if => :password_present?
  validates :password_confirmation, presence: true, :if => :password_present?

  # Scope
  # ----------------------------- 
  scope :active, where(is_active: true)
  scope :inactive, where(is_active: false)
  scope :for_email, lambda {|email_input| where('email like ?', "%#{email_input}%") }

  # Callbacks
  # -----------------------------
  before_save :encrypt_password

  # Custom methods
  # -----------------------------

  def first_name_present?
    !first_name.nil?
  end

  def last_name_present?
    !last_name.nil?
  end

  def password_present?
    !self.password.blank?
  end

  def username_present?
    !username.nil?
  end

  def get_person_name
    return first_name + " " + last_name 
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
