class Person < ActiveRecord::Base
  attr_accessible :odnb_id, :first_name, :last_name, :created_by, :historical_significance, :uncertain, :unlikely, :possible,
  :likely, :certain, :rel_sum, :prefix, :suffix, :search_names_all, :title, :birth_year_type, :ext_birth_year, :alt_birth_year, :death_year_type,
  :ext_death_year, :alt_death_year, :justification, :approved_by, :approved_on, :created_at, :is_approved, :group_list, :gender,
  :is_active, :is_rejected, :edited_by_on
  serialize :rel_sum,Array
  serialize :group_list,Array
  serialize :edited_by_on,Array
  #rel_sum is the relationship summary that is updated whenever a relationship is created or updated
  #rel_sum includes the person the indvidual has a relationship with, the updated max certainty, whether it has been approved, and the relationship id

  # Relationships
  # -----------------------------
  has_many :groups, :through => :group_assignments
  has_many :user_person_contribs
  belongs_to :user
  before_create :init_array

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_unapproved, where("approved_by is null")
  scope :for_odnb_id, lambda {|odnb_id_input| where('odnb_id like ?', "%#{odnb_id_input}%") }
  scope :for_first_name, lambda {|first_name_input| where('first_name like ?', "%#{first_name_input}")}
  scope :for_last_name, lambda {|last_name_input| where('last_name like ?', "%#{last_name_input}")}
  scope :for_first_or_last_name,  lambda {|name_input| find_by_sql("SELECT * FROM people
  where first_name like '#{name_input}' OR last_name like '#{name_input}'")}
  scope :alphabetical, order('last_name').order('first_name');
  scope :for_id, lambda {|id_input| where('id = ?', "#{id_input}") }
  scope :for_first_and_last_name,  lambda {|first_name_input, last_name_input| find_by_sql("SELECT * FROM people
  where first_name like '#{first_name_input}' AND last_name like '#{last_name_input}'")}
  scope :for_similar_first_and_last_name,  lambda {|first_name_input, last_name_input| find_by_sql("SELECT * FROM people
  where first_name like '%#{first_name_input}%' AND last_name like '%#{last_name_input}%'")}
  scope :first_degree_for, lambda {|id_input| 
      select('people.*')
      .joins('join relationships r1 on ((r1.person1_index = people.id) or (r1.person2_index = people.id))')
      .where("people.approved_by is not null and ((r1.person1_index = '#{id_input}') or (r1.person2_index = '#{id_input}'))")
      }

  scope :for_2_people_first_last_name_exact_approved,
    lambda {|person1FirstName, person1LastName, person2FirstName, person2LastName| 
      select('relationships.*')
      .joins('join people p1 on relationships.person1_index = p1.id')
      .joins('join people p2 on relationships.person2_index = p2.id')
      .where("((p1.first_name like '#{person1FirstName}' AND p1.last_name like '#{person1LastName}')
        or
          (p2.first_name like '#{person1FirstName}' AND p2.last_name like '#{person1LastName}'))
        and
          ((p1.first_name like '#{person2FirstName}' AND p1.last_name like '#{person2LastName}')
        or
          (p2.first_name like '#{person2FirstName}' AND p2.last_name like '#{person2LastName}'))")
      .where("relationships.approved_by is not null")}

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

  # Validations
  # -----------------------------
  validates_presence_of :first_name
  # validates_presence_of :last_name
  validates_presence_of :created_by
  validates_presence_of :gender
  # validates_presence_of :uncertain
  # validates_presence_of :unlikely
  # validates_presence_of :possible
  # validates_presence_of :likely
  # validates_presence_of :certain
  #validates_presence_of :rel_sum
  validates_presence_of :birth_year_type
  validates_presence_of :ext_birth_year
  validates_presence_of :death_year_type
  validates_presence_of :ext_death_year
  #validates_presence_of :alt_death_year
  #validates_presence_of :approved_by
  #validates_presence_of :approved_on


  ## first_name must be at least 1 character
  validates_length_of :first_name, :minimum => 1, :allow_blank => true
  ## last_name must be at least 1 character
  validates_length_of :last_name, :minimum => 1, :allow_blank => true
  ## historical_significance must be at least 4 characters
  # validates_length_of :historical_significance, :minimum => 4, :allow_blank => true
  ## prefix must be at least 2 characters
  validates_length_of :prefix, :minimum => 2, :allow_blank => true
  ## suffix must be at least 1 character
  validates_length_of :suffix, :minimum => 1, :allow_blank => true
  ## title must be at least 4 characters
  validates_length_of :title, :minimum => 4, :allow_blank => true
  ## justification must be at least 4 characters
  validates_length_of :justification, :minimum => 4, :allow_blank => true
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This person must be approved on or after the date it was created."
  ## birth year type is one included in the list
  validates_inclusion_of :birth_year_type, :in => DATE_TYPE_LIST
  ## birth year type is one included in the list
  validates_inclusion_of :death_year_type, :in => DATE_TYPE_LIST

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :check_if_approved
  before_update :check_if_approved
  before_update :add_editor_to_edit_by_on

  # Custom Methods
  # -----------------------------
  # make a method that returns all of the two degrees for a person
  # use a array to track what people were added
  # have an array for the people records
  def self.find_first_degree_for(person_id)
    if person_id
      return Person.first_degree_for(person_id)
    else
      return Person.first_degree_for(10000473)
    end
  end

  def self.find_2_degrees_for_person(id)
    peopleRecordsForReturn = []
    if id
      peopleIDArray = []
      searchedPersonRecord = Person.select("id, first_name, last_name, ext_birth_year, ext_death_year, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(id)
      #Add the id and record for the searched person
      peopleIDArray.push(id)
      peopleRecordsForReturn.push(searchedPersonRecord)
      searchedPersonRecord.rel_sum.each do |firstDegreePerson|
        firstDegreePersonID = firstDegreePerson[0]
        firstDegreePersonRecord = Person.select("id, first_name, last_name, ext_birth_year, ext_death_year, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(firstDegreePersonID)
        #Add the id and record for the first degree connection
        peopleIDArray.push(firstDegreePersonID)
        peopleRecordsForReturn.push(firstDegreePersonRecord)

        #for each person who has a first degree relationship with the searched person
        #loop through the first degree person's relationships so that we can find the second degree relationships
        firstDegreePersonRecord.rel_sum.each do |secondDegreePerson|
          secondDegreePersonID = secondDegreePerson[0]
          #check if the person is already in the array and if not, add the array and the record
          if (! peopleIDArray.include?(secondDegreePersonID))
            peopleIDArray.push(secondDegreePersonID)
            secondDegreePersonRecord = Person.select("id, first_name, last_name, ext_birth_year, ext_death_year, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(secondDegreePersonID)
            peopleRecordsForReturn.push(secondDegreePersonRecord)
          end
        end
      end
    end
    return peopleRecordsForReturn
  end

  def add_editor_to_edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = Person.find(self.id).edited_by_on
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
    self.rel_sum = nil
    self.group_list = nil
    self.edited_by_on = nil
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def get_person_name
    return first_name + " " + last_name 
  end

  # searches for people by name
  def self.search_approved(search)
    if search 
      #check that each result in the array is unique
      uniqueArray = []

      searchResultArray = [] 
      #allow searches by person id
      searchIdResult = Person.all_approved.for_id(search.to_i)
      if (! searchIdResult.blank?)
        if (! uniqueArray.include?(searchIdResult[0].id))
          searchResultArray.push(searchIdResult[0])
          uniqueArray.push(searchIdResult[0].id)
        end
      end

      #separate search into several words
      searchArray = search.split(" ")

      #Add exact search for first two words
      if (searchArray.length >= 2)
        exactResult = Person.all_approved.for_first_and_last_name(searchArray[0].capitalize, searchArray[1].capitalize)
        if (! exactResult.blank?)
          if (! uniqueArray.include?(exactResult[0].id))
            searchResultArray.push(exactResult[0])
            uniqueArray.push(exactResult[0].id)
          end
        end
      end

      #Add exact search for first two words
      if (searchArray.length >= 2)
        exactResult = Person.all_approved.for_first_and_last_name(searchArray[0], searchArray[1])
        if (! exactResult.blank?)
          if (! uniqueArray.include?(exactResult[0].id))
            searchResultArray.push(exactResult[0])
            uniqueArray.push(exactResult[0].id)
          end
        end
      end
      
      #Add similar search for first two words
      if (searchArray.length >= 2)
        exactResult = Person.all_approved.for_similar_first_and_last_name(searchArray[0].capitalize, searchArray[1].capitalize)
        if (! exactResult.blank?)
          if (! uniqueArray.include?(exactResult[0].id))
            searchResultArray.push(exactResult[0])
            uniqueArray.push(exactResult[0].id)
          end
        end
      end

      #Add similar search for first two words
      if (searchArray.length >= 2)
        exactResult = Person.all_approved.for_similar_first_and_last_name(searchArray[0], searchArray[1])
        if (! exactResult.blank?)
          if (! uniqueArray.include?(exactResult[0].id))
            searchResultArray.push(exactResult[0])
            uniqueArray.push(exactResult[0].id)
          end
        end
      end

      #for each word add search results
      searchArray.each do |searchWord|
        searchResult = Person.all_approved.for_first_or_last_name(searchWord.capitalize)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end
      return searchResultArray
    end
  end

  # searches for people by name
  def self.search_all(search)
    if search 
      #check that each result in the array is unique
      uniqueArray = []

      searchResultArray = [] 
      #allow searches by person id
      searchIdResult = Person.for_id(search.to_i)
      if (! searchIdResult.blank?)
        if (! uniqueArray.include?(searchIdResult[0].id))
          searchResultArray.push(searchIdResult[0])
          uniqueArray.push(searchIdResult[0].id)
        end
      end

      #separate search into several words
      searchArray = search.split(" ")

      #Add exact search for first two words
      if (searchArray.length >= 2)
        exactResult = for_first_and_last_name(searchArray[0].capitalize, searchArray[1].capitalize)
        if (! exactResult.blank?)
          if (! uniqueArray.include?(exactResult[0].id))
            searchResultArray.push(exactResult[0])
            uniqueArray.push(exactResult[0].id)
          end
        end
      end
      
      #Add similar search for first two words
      if (searchArray.length >= 2)
        exactResult = for_similar_first_and_last_name(searchArray[0].capitalize, searchArray[1].capitalize)
        if (! exactResult.blank?)
          if (! uniqueArray.include?(exactResult[0].id))
            searchResultArray.push(exactResult[0])
            uniqueArray.push(exactResult[0].id)
          end
        end
      end

      #for each word add search results
      searchArray.each do |searchWord|
        searchResult = for_first_or_last_name(searchWord.capitalize)
        if (! searchResult.blank?)
          searchResult.each do |searchResultRecord|
            if (! uniqueArray.include?(searchResultRecord.id))
              searchResultArray.push(searchResultRecord)
              uniqueArray.push(searchResultRecord.id)
            end
          end
        end
      end
      return searchResultArray
    end
  end
end

