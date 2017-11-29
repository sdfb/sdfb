class User < ActiveRecord::Base
  attr_accessible :about_description, :affiliation, :email, :first_name, 
                  :is_active, :last_name, 
                  :user_type, :prefix, :orcid, 
                  :username, :created_at, 
                  :password, :password_confirmation

  attr_accessor :password, :password_confirmation

  # Relationships
  # -----------------------------
  has_many :user_rel_contribs
  has_many :people
  has_many :relationships
  has_many :groups
  has_many :group_assignments
  has_many :rel_cat_assigns
  has_many :relationship_categories
  has_many :relationship_types
  

  # Validations
  # -----------------------------
  validates :is_active, :inclusion => {:in => [true, false]}

  # username must be at least 6 characters long
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :minimum => 6, :allow_blank => true
  validates_format_of :username, :with => /\A[-\w\._@]+\z/i, :message => "Your username should only contain letters, numbers, or .-_@"

  ## first_name must be at least 1 character
  validates_presence_of :first_name
  validates_length_of :first_name, :minimum => 1, :allow_blank => true

  ## last_name must be at least 1 character
  validates_presence_of :last_name
  validates_length_of :last_name, :minimum => 1, :allow_blank => true

  #user must be one of three types: standard, curator, admin
  validates_presence_of :user_type
  validates :user_type, :inclusion => {:in => SDFB::USER_TYPES_LIST}

  # email must be present and be a valid email format
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+\z/i
  
  # password must be present and at least 4 characters long, with a confirmation
  # password must have one number, one letter, and be at least 6 characters
  validates_presence_of :password, :on => :create
  validates_presence_of :password_confirmation, :on => :create
  validates_format_of :password, :with =>  /\A(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){6,}\z/, :message => "Your password must include at least one number, at least one letter, and at least 7 characters.", if: "self.password.present?"
  validates :password, confirmation: true, if: "self.password.present?"
  validates :password_confirmation, presence: true, if: "self.password.present?"

  # Scope
  # ----------------------------- 

  # Callbacks
  # -----------------------------
  after_save :encrypt_password
  after_save :refresh_token

  # Custom methods
  # -----------------------------
  def as_json(options={})
    options[:except] ||= [:password_digest, :password_reset_sent_at, :password_reset_token]
    options[:methods] ||= [:points, :contributions] unless options[:minimal]
    super(options)
  end

  # -----------------------------
  def points
    return 0 unless self.id
    points = 0
    Group.for_user(self.id).where('is_approved = ?', true).to_a.each do |contrib|
      points += 1
    end
    GroupAssignment.for_user(self.id).where('is_approved = ?', true).to_a.each do |contrib|
      points += 1
    end
    Person.for_user(self.id).where('is_approved = ?', true).to_a.each do |contrib|
      points += 1
    end
    Relationship.for_user(self.id).where('is_approved = ?', true).to_a.each do |contrib|
      points += 1
    end
    UserRelContrib.for_user(self.id).where('is_approved = ?', true).to_a.each do |contrib|
      points += 1
    end
    # THIS IS THE CODE FOR COUNTING APPROVALS IN SCORES.
    # if self.user_type == "Curator" || self.user_type == "Admin"
    #     points += Group.approved_user(self.id).to_a.count()
    #     points += GroupAssignment.approved_user(self.id).to_a.count()
    #     points += Person.approved_user(self.id).to_a.count()
    #     points += Relationship.approved_user(self.id).to_a.count()
    #     points += UserRelContrib.approved_user(self.id).to_a.count()
    # end
    return points
  end

  # -----------------------------
  def contributions
    obj = {}
    return obj unless self.id 
    obj[:people] = Person.all_approved.for_user(self.id)
    .sort_by{|g| g.approved_on}.reverse.collect do |g| 
      {
        id: g.id, 
        name: g.display_name, 
        is_approved: g.is_approved
      }
    end
    obj[:relationships] = Relationship.all_approved.for_user(self.id)
    .sort_by{|g| g.approved_on}.reverse.collect do |g| 
      {
        id: g.id, 
        people: g.get_both_names, 
        is_approved: g.is_approved
      }
    end
    obj[:relationship_types] = UserRelContrib.all_approved.for_user(self.id)
    .sort_by{|g| g.approved_on || Date.new(0)}.reverse.collect do |g| 
      {
        id: g.id, 
        people: g.relationship.get_both_names, 
        type: g.relationship_type.name,
        is_approved: g.is_approved
      }
    end
    obj[:groups] = Group.all_approved.for_user(self.id)
    .sort_by{|g| g.approved_on}.reverse.collect do |g| 
      {
        id: g.id, 
        name: g.name, 
        is_approved: g.is_approved
      }
    end
    obj[:group_assignments] = GroupAssignment.all_approved.for_user(self.id)
    .sort_by{|g| g.approved_on}.reverse.collect do |g|
      {
        id: g.id, 
        person_name: g.person.display_name, 
        group_name: g.group.name, 
        is_approved: g.is_approved
      }
    end
    obj
  end

  # Class-level method for logging in a person 
  # -----------------------------
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user.update_attribute(:auth_token, SecureRandom.urlsafe_base64)
      user
    else
      nil
    end
  end

  # -----------------------------
  def encrypt_password
    if password.present?
      self.update_column(:password_digest, BCrypt::Password.create(password))
    end
  end

  # -----------------------------
  def refresh_token
    if password.present?
      self.update_column :auth_token, SecureRandom.urlsafe_base64
      self.update_column :password_reset_token, SecureRandom.urlsafe_base64
    end
  end 
  
  # -----------------------------
  def send_password_reset  
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.zone.now  
    self.save!
    UserMailer.password_reset(self).deliver  
  end  
end
