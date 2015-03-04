class Person < ActiveRecord::Base
  attr_accessible :odnb_id, :first_name, :last_name, :created_by, :historical_significance, :uncertain, :unlikely, :possible,
  :likely, :certain, :rel_sum, :prefix, :suffix, :search_names_all, :title, :birth_year_type, :ext_birth_year, :alt_birth_year, :death_year_type,
  :ext_death_year, :alt_death_year, :justification, :approved_by, :approved_on, :created_at, :is_approved, :group_list, :gender,
  :is_active, :is_rejected, :edited_by_on, :display_name
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
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
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
  scope :all_members_of_a_group, lambda {|groupID| 
      select('people.*')
      .joins('join group_assignments ga on (people.id = ga.person_id)')
      .where('(ga.group_id = ?)', groupID)}
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
  GENDER_LIST = ["female", "male","unknown"]

  # Validations
  # -----------------------------
  validates_presence_of :first_name
  # validates_presence_of :last_name
  validates_presence_of :created_by
  validates_presence_of :gender
  #validates_presence_of :display_name #####comment back in
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
  ## gender must be included in the gender list
  validates_inclusion_of :gender, :in => GENDER_LIST

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

  #this is a scope for the shared group, meaning that people that this returns are in two groups
  def self.all_members_of_2_groups(group1ID, group2ID)
    peopleRecordsForReturn = []
    #find all members of the first group
    peopleInGroup1 = Person.all_members_of_a_group(group1ID)
    #find all members of the second group and get their list of IDs
    idsForPeopleInGroup2 = Person.all_members_of_a_group(group2ID).map { |a| a.id }

    #loop through all members of the first group and if their id are in the list of 
    #ids for people in the second group then add them to the return array
    peopleInGroup1.each do |memberRecord|
      if (idsForPeopleInGroup2.include?(memberRecord.id))
        peopleRecordsForReturn.push(memberRecord)
      end
    end
    return peopleRecordsForReturn
  end

  def self.find_2_degrees_for_person(id)
    peopleRecordsForReturn = []
    if id
      peopleIDArray = []
      searchedPersonRecord = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(id)
      #Add the id and record for the searched person
      peopleIDArray.push(id)
      peopleRecordsForReturn.push(searchedPersonRecord)
      searchedPersonRecord.rel_sum.each do |firstDegreePerson|
        firstDegreePersonID = firstDegreePerson[0]
        firstDegreePersonRecord = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type,  rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(firstDegreePersonID)
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
            secondDegreePersonRecord = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(secondDegreePersonID)
            peopleRecordsForReturn.push(secondDegreePersonRecord)
          end
        end
      end
    end
    return peopleRecordsForReturn
  end

  def self.find_2_degrees_for_shared_network(person1_id, person2_id)
    peopleRecordsForReturn = []
    if person1_id
      peopleIDArray = []

      #find the person record for searched person 1
      searchedPerson1Record = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(person1_id)
      #Add the id and record for the searched person 1
      peopleIDArray.push(person1_id)
      peopleRecordsForReturn.push(searchedPerson1Record)

      #find the person record for searched person 2
      searchedPerson2Record = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(person2_id)
      #Add the id and record for the searched person 2
      peopleIDArray.push(person2_id)
      peopleRecordsForReturn.push(searchedPerson2Record)

      # go through each the relsum for searched person 1 and compare that entries with searched person 2
      searchedPerson1Record.rel_sum.each do |firstDegreePerson|
        firstDegreePersonID = firstDegreePerson[0]
        #don't read the searched person1 and searched person2 records
        if (firstDegreePersonID != person1_id)
          if (firstDegreePersonID != person2_id) 
            #Add the id and record for the first degree connection for person 1 if it is a shared connection with person 2
            #loop through person 2's rel_sum to perform the check for that person
            if (! searchedPerson2Record.rel_sum.nil?)
              searchedPerson2Record.rel_sum.each do |firstDegreePersonForSearchedP2|
                # if the first degree person is shared between the the searched person 1 and searched person 2 then add the record
                # don't include the originally searched person 1 and person 2
                if (firstDegreePersonForSearchedP2[0] != person1_id)
                  if (firstDegreePersonForSearchedP2[0] != person2_id)
                    if (firstDegreePersonForSearchedP2[0] == firstDegreePersonID)
                      firstDegreePersonRecord = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type,  rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(firstDegreePersonID)
                      peopleIDArray.push(firstDegreePersonID)
                      peopleRecordsForReturn.push(firstDegreePersonRecord)

                      #for each person who has a first degree relationship with the searched person
                      #loop through the first degree person's relationships so that we can find the second degree relationships
                      if (! firstDegreePersonRecord.rel_sum.nil?)
                        firstDegreePersonRecord.rel_sum.each do |secondDegreePersonRel|
                          secondDegreePersonID = secondDegreePersonRel[0]
                          #check if the person is already in the array
                          if (! peopleIDArray.include?(secondDegreePersonID))
                            #find the record of the second degree person
                            secondDegreePersonRecord = Person.select("id, first_name, last_name, display_name, ext_birth_year, birth_year_type, ext_death_year, death_year_type, rel_sum, group_list, historical_significance, odnb_id, prefix, suffix, title").find(secondDegreePersonID)

                            #if the person is not in the array already
                            secondDegreePersonRecord.rel_sum.each do |thirdDegreePerson|
                              thirdDegreePersonID = thirdDegreePerson[0]
                              #check if person1 and person 2 are within their first degree and if they are then return
                              if ((thirdDegreePersonID == person1_id) || (thirdDegreePersonID == person2_id))
                                peopleIDArray.push(secondDegreePersonID)
                                peopleRecordsForReturn.push(secondDegreePersonRecord)
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
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

  def autocomplete_name
    "#{self.display_name} (#{self.ext_birth_year})"
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def get_person_name
    person_name = ""
    if (prefix != "")
      person_name += prefix
    end
    if (first_name != "")
      if (person_name == "")
        person_name += first_name
      else
        person_name += " " + first_name
      end
    end
    if (last_name != "")
      if (person_name == "")
        person_name += last_name
      else
        person_name += " " + last_name
      end
    end
    if (suffix != "")
      if (person_name == "")
        person_name += suffix
      else
        person_name += " " + suffix
      end
    end
    if (title != "")
      if (person_name == "")
        person_name += title
      else
        person_name += " " + title
      end
    end
      
    return person_name
  end

  # searches for people by name
  def self.search_approved(search)
    if search 
      return Person.all_approved.for_id(search.to_i)
    end
  end

  # searches for people by name
  def self.search_all(search)
    if search 
      return Person.all.for_id(search.to_i)
    end
  end
end

