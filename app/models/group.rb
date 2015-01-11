class Group < ActiveRecord::Base
  attr_accessible :created_by, :description, :name, :justification, :approved_by, :approved_on, 
  :created_at, :is_approved, :person_list, :start_year, :end_year, :is_active, :is_rejected, :edited_by_on
  serialize :person_list,Array
  serialize :edited_by_on,Array
  
  # Relationships
  # -----------------------------
  has_many :people, :through => :group_assignments
  has_many :group_categories, :through => :group_cat_assigns
  has_many :user_group_contribs
  belongs_to :user

  # Validations
  # -----------------------------
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :created_by
  #validates_presence_of :approved_by
  #validates_presence_of :approved_on
  ## name must be at least 3 characters
  validates_length_of :name, :minimum => 3
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This group must be approved on or after the date it was created."
  validates :start_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :start_year_present?
  validates :start_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :start_year_present?
  validates :end_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :end_year_present?
  validates :end_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :end_year_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :for_id, lambda {|id_input| where('id = ?', "#{id_input}") }
  scope :exact_name_match, lambda {|search_input| where('name like ?', "#{search_input}") }
  scope :similar_name_match, lambda {|search_input| where('name like ?', "%#{search_input}%") }

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :check_if_approved
  before_update :check_if_approved
  before_update :add_editor_to_edit_by_on

  # Custom Methods
  # -----------------------------
  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = Group.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.edited_by_on)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end
  end

  def init_array
    self.person_list = nil
    self.edited_by_on = nil
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end

  def check_if_approved
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  # searches for people by name
  def self.search_approved(search)
    if search 
      #check that each result in the array is unique
      uniqueArray = []

      searchResultArray = [] 
      #allow searches by group id
      searchIdResult = Group.for_id(search.to_i).all_approved
      if (! searchIdResult.blank?)
        if (! uniqueArray.include?(searchIdResult[0].id))
          searchResultArray.push(searchIdResult[0])
          uniqueArray.push(searchIdResult[0].id)
        end
      end

      #check for exact matches for the entire string
      searchExactResult = Group.all_approved.exact_name_match(search)
      if (! searchExactResult.blank?)
        if (! uniqueArray.include?(searchExactResult[0].id))
          searchResultArray.push(searchExactResult[0])
          uniqueArray.push(searchExactResult[0].id)
        end
      end

      #separate search into several words
      searchArray = search.split(" ")

      #for each word add exact search results
      searchArray.each do |searchWord|
        searchResult = Group.all_approved.exact_name_match(searchWord.capitalize)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end

      #for each word add exact search results
      searchArray.each do |searchWord|
        searchResult = Group.all_approved.exact_name_match(searchWord)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end

      #for each word add similar search results
      searchArray.each do |searchWord|
        searchResult = Group.all_approved.similar_name_match(searchWord.capitalize)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end

      #for each word add similar search results
      searchArray.each do |searchWord|
        searchResult = Group.all_approved.similar_name_match(searchWord)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end
      #return searchResultArray.size
      return searchResultArray
    end
  end

  # searches for people by name
  def self.search_all(search)
    if search 
      #check that each result in the array is unique
      uniqueArray = []

      searchResultArray = [] 
      #allow searches by group id
      searchIdResult = Group.for_id(search.to_i)
      if (! searchIdResult.blank?)
        if (! uniqueArray.include?(searchIdResult[0].id))
          searchResultArray.push(searchIdResult[0])
          uniqueArray.push(searchIdResult[0].id)
        end
      end

      #separate search into several words
      searchArray = search.split(" ")

      #for each word add exact search results
      searchArray.each do |searchWord|
        searchResult = exact_name_match(searchWord.capitalize)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end

      #for each word add exact search results
      searchArray.each do |searchWord|
        searchResult = exact_name_match(searchWord)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end

      #for each word add similar search results
      searchArray.each do |searchWord|
        searchResult = similar_name_match(searchWord.capitalize)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end

      #for each word add similar search results
      searchArray.each do |searchWord|
        searchResult = similar_name_match(searchWord)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end
      #return searchResultArray.size
      return searchResultArray
    end
  end
end