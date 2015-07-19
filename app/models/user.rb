class User < ActiveRecord::Base
  attr_accessible :about_description, :affiliation, :email, :first_name, :is_active, :last_name, :password,
  :password_confirmation, :user_type, :password_hash, :password_salt, :prefix, :orcid, :curator_revoked, :username, :created_at
  attr_accessor :password

  # Callbacks
  # -----------------------------
  before_save :encrypt_password

  # Relationships
  # -----------------------------
  has_many :user_group_contribs
  has_many :user_person_contribs
  has_many :user_rel_contribs
  has_many :people
  has_many :relationships
  has_many :groups
  has_many :group_assignments
  has_many :group_cat_assigns
  has_many :group_categories
  has_many :rel_cat_assigns
  has_many :relationship_categories
  has_many :relationship_types
  

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
  validates_format_of :username, :with => /\A[-\w\._@]+\z/i, :message => "Your username should only contain letters, numbers, or .-_@"
  #validates_format_of :email, :with => /^[\w]([^@\s,;]+)@(([a-z0-9.-]+\.)+(com|edu|org|net|gov|mil|biz|info))$/i
  # This email regular expression validation allows for a wider variety of email types
  validates_format_of :email, :with => /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/i
  # password must have one number, one letter, and be at least 6 characters
  validates_format_of :password, :with =>  /\A(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){6,}\z/, :message => "Your password must include at least one number, at least one letter, and at least 7 characters.", :if => :password_present?
  validates :password, confirmation: true, :if => :password_present?
  validates :password_confirmation, presence: true, :if => :password_present?

  # Scope
  # ----------------------------- 
  scope :active, -> { where(is_active: true) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :for_email, -> (email_input) { where('email like ?', "%#{email_input}%") }
  scope :all_recent, -> { order(created_at: :desc) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Callbacks
  # -----------------------------
  before_save :encrypt_password
  before_create { generate_token(:auth_token) }  

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
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_digest = BCrypt::Password.create(password)
    end
  end

  def generate_token(column)  
    begin  
      self[column] = SecureRandom.urlsafe_base64  
    end while User.exists?(column => self[column])  
  end  
  
  def send_password_reset  
    generate_token(:password_reset_token)  
    self.password_reset_sent_at = Time.zone.now  
    save!  
    UserMailer.password_reset(self).deliver  
  end  
end
