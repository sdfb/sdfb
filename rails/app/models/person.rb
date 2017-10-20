class Person < ActiveRecord::Base
  # Misc Constants
  # -----------------------------
  GENDER_LIST    = ["female", "male", "gender_nonconforming"]

  include TrackLastEdit
  include WhitespaceStripper
  include Approvable

  # TODO: Figure out if :group_list is actually used anywhere.
  # TODO: Figure out how many of these actually need to be writable.

  attr_accessible :odnb_id, 
                  :prefix, :title, :first_name, :last_name, :suffix, :display_name, :aliases, :search_names_all,
                  :historical_significance, :justification,  :gender,                
                  # :uncertain, :unlikely, :likely, :possible, :certain,       # none of these appear in the code. - DGN 3/11/2017            
                  :birth_year_type, :ext_birth_year, :alt_birth_year,       
                  :death_year_type, :ext_death_year, :alt_death_year,
                  :rel_sum, :group_list, :bibliography,
                  :created_by, :created_at

  serialize :rel_sum,    Array
  serialize :group_list, Array

  # rel_sum is the relationship summary that is updated whenever a relationship 
  # is created or updated. rel_sum includes the person the indvidual has a 
  # relationship with, the updated max certainty, whether it has been approved, 
  # and the relationship id

  # Relationships
  # -----------------------------
  has_many :group_assignments,    dependent: :destroy
  has_many :groups, through: :group_assignments
  has_many :user_person_contribs, dependent: :destroy
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :all_recent,  -> { order(updated_at: :desc) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :for_odnb_id, -> (odnb_id_input) { where('odnb_id like ?', "%#{odnb_id_input}%") }
  scope :for_first_name, -> (first_name_input) { where('first_name like ?', "%#{first_name_input}")}
  scope :for_last_name, -> (last_name_input) { where('last_name like ?', "%#{last_name_input}")}
  scope :for_first_or_last_name, -> (name_input) { where('(first_name like ?) || (last_name like ?)', "%#{name_input}", "%#{name_input}")}
  scope :alphabetical, -> { order(last_name: :asc, first_name: :asc) }
  scope :for_id, -> (id_input) { where('id = ?', "#{id_input}") }
  scope :for_first_and_last_name,  -> (name_input) { where('(first_name like ?) AND (last_name like ?)', "%#{name_input}", "%#{name_input}")}
  scope :all_members_of_a_group, -> (groupID) { 
      select('people.*')
      .joins('join group_assignments ga on (people.id = ga.person_id)')
      .where('(ga.group_id = ? and ga.approved_by is not null)', groupID)}
  scope :rels_for_id, -> (id, sdata, edate) {
  	select('id, rel_sum')
  	.where("id = ? and (ext_birth_year < ? or ext_death_year > ?)", '%#{id}', '%#{edate}', '%#{sdate}')}
  scope :order_by_sdfb_id, -> { order(:id) }



  # Validations
  # -----------------------------
  # validates_presence_of :first_name
  # validates_presence_of :last_name
  validates_presence_of :created_by
  validates_presence_of :gender
  validates_presence_of :birth_year_type
  validates_presence_of :ext_birth_year
  validates_presence_of :death_year_type
  validates_presence_of :ext_death_year
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
  validates_length_of :title, :minimum => 1, :allow_blank => true
  ## justification must be at least 4 characters
  validates_length_of :justification, :minimum => 4, :allow_blank => true
  ## birth year type is one included in the list
  validates_inclusion_of :birth_year_type, :in => SDFB::DATE_TYPES
  ## birth year type is one included in the list
  validates_inclusion_of :death_year_type, :in => SDFB::DATE_TYPES
  ## gender must be included in the gender list
  validates_inclusion_of :gender, :in => GENDER_LIST
  # custom validation that checks the birth and death dates
  validate :check_birth_death_years

  # Callbacks
  # ----------------------------- 
  before_create  :init_rel_sum_and_group_list
  before_create  :check_if_approved
  before_create  :populate_search_names
  before_update  :check_if_approved_and_update_edit
  before_save    :check_birth_death_years
  before_save    :add_display_name_if_blank
  before_destroy :delete_associated_relationships
  before_save    { remove_trailing_spaces(:prefix, :title, :first_name, :last_name, :suffix, :display_name, :aliases)}



  # Custom Methods
  # -----------------------------

  def approved_groups
    groups = self.group_assignments.where('group_assignments.is_approved = ?', true).map{|ga| ga.group_id}
    Group.find(groups)
  end

  # if the display name is blank then add one
  def add_display_name_if_blank
    if self.display_name.blank?
      new_display_name = self.get_person_name
      self.display_name = new_display_name
    end
  end

  def relationships(certainty=SDFB::DEFAULT_CONFIDENCE)
    Relationship.all_approved.where("person1_index = ? OR person2_index = ?", self.id, self.id).where(max_certainty: (certainty..100))
  end


  # if you delete a person, delete any relationships associated with him/her
  #-----------------------------------------------------------------------------
  def delete_associated_relationships
    # find all associated relationships
    associated_relationships = Relationship.all_for_person(self.id)
    # go through and delete each one
    associated_relationships.each do |u|
      Relationship.destroy(u.id)
    end
  end

  # checks that death year is on or after birth year and that birth 
  # and death years meet SDFB::EARLIEST_YEAR and SDFB::LATEST_YEAR rules
  #-----------------------------------------------------------------------------
  def check_birth_death_years

    #initiate variables for checking if birth year and death year are valid
    invalid_birth_year_format = false
    invalid_death_year_format = false

    # if the birth year converted to an integer is 0 then the date was not an integer
    if self.ext_birth_year.present?
      if self.ext_birth_year.to_i == 0
        errors.add(:ext_birth_year, "Please check the format of the birth year.")
        invalid_birth_year_format = true
      # if valid format continue checking
      else
        # check that birth year is before SDFB::LATEST_YEAR or throw error
        if self.ext_birth_year.to_i > SDFB::LATEST_YEAR
          errors.add(:ext_birth_year, "The birth year must be before #{SDFB::LATEST_YEAR}")
        end
      end
    end

    # if the death year converted to an integer is 0 then the date was not an integer
    if self.ext_death_year.present?
      if self.ext_death_year.to_i == 0
        errors.add(:ext_death_year, "Please check the format of the death year.")
        invalid_death_year_format = true
      # if valid format continue checking
      else
        # check that death year is after SDFB::EARLIEST_YEAR or throw error
        if self.ext_death_year.to_i < SDFB::EARLIEST_YEAR
          errors.add(:ext_death_year, "The death year must be after #{SDFB::EARLIEST_YEAR}")
        end
      end
    end

    # perform this check if both years are entered and the birth year and the death year formats are valid
    if (! (self.ext_birth_year.blank? || self.ext_death_year.blank?)) && ((invalid_birth_year_format == false) && (invalid_death_year_format == false))
      # check that birth year is equal to or before death year
      if (self.ext_birth_year.to_i > self.ext_death_year.to_i)
        errors.add(:ext_birth_year, "The birth year must be less than or equal to the death year")
        errors.add(:ext_death_year, "The death year must be greater than or equal to the birth year")
      end
    end
  end



  #populate search names with all permutations of the name on create and if empty on edit
  #-----------------------------------------------------------------------------
  def populate_search_names
    search_names_all_input = ""
    #add all permutations to the search names all  
    if (! self.prefix.blank?)
      if (! self.first_name.blank?)
        # Prefix FirstName
        if (! search_names_all_input.blank?)
          search_names_all_input += ", "
        end
        search_names_all_input += self.prefix + " " + self.first_name
        if (! self.last_name.blank?)
          # Prefix FirstName LastName
          if (! search_names_all_input.blank?)
            search_names_all_input += ", "
          end
          search_names_all_input += self.prefix + " " + self.first_name + " " + self.last_name

          if (! self.suffix.blank?)
            # Prefix FirstName LastName Suffix
            if (! search_names_all_input.blank?)
              search_names_all_input += ", "
            end
            search_names_all_input += self.prefix + " " + self.first_name + " " + self.last_name + " " + self.suffix
          end
          if (! self.title.blank?)
            # Prefix FirstName LastName Title
            if (! search_names_all_input.blank?)
              search_names_all_input += ", "
            end
            search_names_all_input += self.prefix + " " + self.first_name + " " + self.last_name + " " + self.title
          end
        end
        if (! self.suffix.blank?)
          # Prefix FirstName Suffix
          if (! search_names_all_input.blank?)
            search_names_all_input += ", "
          end
          search_names_all_input += self.prefix + " " + self.first_name + " " + self.suffix
        end
      end
      if (! self.last_name.blank?)
        # Prefix LastName
        if (! search_names_all_input.blank?)
            search_names_all_input += ", "
        end
        search_names_all_input += self.prefix + " " + self.last_name
        if (! self.suffix.blank?)
          # Prefix LastName Suffix
          if (! search_names_all_input.blank?)
            search_names_all_input += ", "
          end
          search_names_all_input += self.prefix + " " + self.last_name + " " + self.suffix
        end
      end
    end
    if (! self.first_name.blank?)
      # FirstName
      if (! search_names_all_input.blank?)
        search_names_all_input += ", "
      end
      search_names_all_input += self.first_name
      if (! self.last_name.blank?)
        # FirstName LastName
        if (! search_names_all_input.blank?)
          search_names_all_input += ", "
        end
        search_names_all_input += self.first_name + " " +  self.last_name
        if (! self.suffix.blank?)
          # FirstName LastName Suffix
          if (! search_names_all_input.blank?)
            search_names_all_input += ", "
          end
          search_names_all_input += self.first_name + " " + self.last_name + " " + self.suffix
        end
        if (! self.title.blank?)
          # FirstName LastName Title
          if (! search_names_all_input.blank?)
            search_names_all_input += ", "
          end
          search_names_all_input += self.first_name + " " + self.last_name + " " + self.title
        end
      end
      if (! self.suffix.blank?)
        # FirstName Suffix
        if (! search_names_all_input.blank?)
          search_names_all_input += ", "
        end
        search_names_all_input += self.first_name + " " + self.suffix
      end
    end

    if (! self.aliases.blank?)
      # Aliases + Alternate Names
      name_list = self.aliases.split(',')
      for name in name_list
        search_names_all_input += ", " + name
      end
    end

    self.search_names_all = search_names_all_input
  end

  # make a method that returns all of the two degrees for a person
  # use a array to track what people were added
  # have an array for the people records
  #-----------------------------------------------------------------------------
  def self.find_first_degree_for_person(person_id, 
                                        min_confidence=SDFB::DEFAULT_CONFIDENCE,
                                        max_confidence=SDFB::DEFAULT_MAX_CONFIDENCE,
                                        min_year=SDFB::EARLIEST_YEAR, 
                                        max_year=SDFB::LATEST_YEAR,
                                        load_rels=true)
  	peopleRecordsForReturn = {}
	  @PersonRecord = Person.select("id, rel_sum, display_name").where("id = ?", person_id)
    @adjustedrel = []
		@PersonRecord[0]['rel_sum'].each do |firstDegreePerson|
			firstDegreePersonID = firstDegreePerson[0]

      if ((firstDegreePerson[3].to_i >= min_year) || ((firstDegreePerson[4].to_i <= max_year) && (firstDegreePerson[3].to_i >= min_year)))
  			if ((firstDegreePerson[1].to_i >= min_confidence) && (firstDegreePerson[1].to_i <= max_confidence) && @adjustedrel.length <= 100)
          @adjustedrel.push(firstDegreePerson)
          if (load_rels)
          	@firstDegreePersonQuery = Person.select("id, display_name, rel_sum").where("id = ?", firstDegreePersonID)
    				@firstDegreePersonRel = []
            @firstDegreePersonQuery[0].rel_sum.each do |rel|
              if ((rel[3].to_i >= min_year) || ((rel[4].to_i <= max_year) && (rel[3].to_i >= min_year)))
                if ((rel[1].to_i >= min_confidence) && (rel[1].to_i <= max_confidence ) && @firstDegreePersonRel.length <= 100)
                  @firstDegreePersonRel.push(rel)
                end
              end
            end
            peopleRecordsForReturn[@firstDegreePersonQuery[0].id] = {'rel_sum' => @firstDegreePersonRel, 'display_name' => @firstDegreePersonQuery[0].display_name}   
          else
           @firstDegreePersonQuery = Person.select("id, display_name").where("id = ?", firstDegreePersonID)
           peopleRecordsForReturn[@firstDegreePersonQuery[0].id] = {'display_name' => @firstDegreePersonQuery[0].display_name}   
          end

        end
      end
		end
    peopleRecordsForReturn[@PersonRecord[0].id] = {'rel_sum' => @adjustedrel, 'display_name' => @PersonRecord[0].display_name}
		return peopleRecordsForReturn
  end

  def self.find_two_degree_for_person(id, confidence_range, date_range, rel_type_filter)
    twoPeopleRecordsForReturn = {}
    if (id)
      person_id = id
    else
      person_id = SDFB::FRANCIS_BACON
    end
    if (confidence_range)
      min_confidence = confidence_range.split(",")[0].to_i
      max_confidence = confidence_range.split(",")[1].to_i
    else
      min_confidence = 60
      max_confidence = 100
    end
    if (date_range)
      min_year = date_range.split(",")[0].to_i
      max_year = date_range.split(",")[1].to_i
    else
      min_year = SDFB::EARLIEST_BIRTH_YEAR
      max_year = SDFB::LATEST_DEATH_YEAR
    end
    @zeroDegreePerson = self.find_first_degree_for_person(person_id, min_confidence, max_confidence, min_year, max_year, true)
    #limit first degree node display to nodes of degree <100, second degree node display to nodes of degree <=50
    if @zeroDegreePerson[person_id.to_i]['rel_sum'].length < 100
    if @zeroDegreePerson[person_id.to_i]['rel_sum'].length <= 50
        @zeroDegreePerson[person_id.to_i]['rel_sum'].each do |firstDegreePerson|
            #check that relationship is within the date and confidence range
            if ((firstDegreePerson[3].to_i >= min_year) || ((firstDegreePerson[4].to_i <= max_year) && (firstDegreePerson[3].to_i >= min_year)))
                if ((firstDegreePerson[1].to_i >= min_confidence) && (firstDegreePerson[1].to_i <= max_confidence))
                    firstDegreePersonID = firstDegreePerson[0]

                    if (rel_type_filter != "")
                      relID = Relationship.select("id").where("person1_index = ? AND person2_index = ? OR person1_index = ? AND person2_index = ? ", @zeroDegreePerson[person_id.to_i]['id'], firstDegreePersonID, firstDegreePersonID, @zeroDegreePerson[person_id.to_i]['id'])
                      rel_type_id = UserRelContrib.select("relationship_type_id").where("relationship_id = ?", relID)
                      if (rel_type_id == rel_type_filter)
                        @firstDegreePerson = self.find_first_degree_for_person(firstDegreePersonID, min_confidence, max_confidence, min_year, max_year, false)
                        twoPeopleRecordsForReturn.update(@firstDegreePerson)
                      end
                    else
                      @firstDegreePerson = self.find_first_degree_for_person(firstDegreePersonID, min_confidence, max_confidence, min_year, max_year, false)
                      twoPeopleRecordsForReturn.update(@firstDegreePerson)
                    end

                end
            end
        end
        end
    else
      display_name = Person.select("display_name").where("id = ?", person_id)
      return ["nodelimit", person_id, display_name]
    end
    twoPeopleRecordsForReturn.update(@zeroDegreePerson)
    return twoPeopleRecordsForReturn
  end

  #-----------------------------------------------------------------------------
  def self.find_relationship(id, rel_sum)
    rel_sum.each do |rel|
      if rel[0].to_i == id
        return rel
      end
    end
    return "None"
  end

  #-----------------------------------------------------------------------------
  def self.find_two_degree_for_network(person_id1, person_id2, confidence_range, date_range, var1)
    twoPeopleRecordsForReturn = {}
    if (confidence_range)
      min_confidence = confidence_range.split(",")[0].to_i
      max_confidence = confidence_range.split(",")[1].to_i
    else
      min_confidence = 60
      max_confidence = 100
    end
    if (date_range)
      min_year = date_range.split(",")[0].to_i
      max_year = date_range.split(",")[1].to_i
    else
      min_year = SDFB::EARLIEST_BIRTH_YEAR
      max_year = SDFB::LATEST_DEATH_YEAR
    end
    @zeroDegreePerson1 = self.find_first_degree_for_person(person_id1, min_confidence, max_confidence, min_year, max_year, true)
		@zeroDegreePerson2 = self.find_first_degree_for_person(person_id2, min_confidence, max_confidence, min_year, max_year, true)
		@zeroDegreePerson2Rel = {}
		@zeroDegreePerson2Rel[person_id2] = person_id2
    if @zeroDegreePerson2[person_id2.to_i]['rel_sum'].length > 100
      @found = self.find_relationship(person_id1.to_i, @zeroDegreePerson2[person_id2.to_i]['rel_sum'])
      display_name1 = Person.select("display_name").where("id = ?", person_id1.to_i)
      display_name2 = Person.select("display_name").where("id = ?", person_id2.to_i)        
      return ["nodelimit_network", @found[2], person_id1.to_i, person_id2.to_i, display_name1, display_name2]
    end
    if @zeroDegreePerson1[person_id1.to_i]['rel_sum'].length > 100
      @found = self.find_relationship(person_id2.to_i, @zeroDegreePerson1[person_id1.to_i]['rel_sum'])
      display_name1 = Person.select("display_name").where("id = ?", person_id1.to_i)
      display_name2 = Person.select("display_name").where("id = ?", person_id2.to_i)
      return ["nodelimit_network", @found[2], person_id1.to_i, person_id2.to_i, display_name1, display_name2]

    end
		@zeroDegreePerson2[person_id2.to_i]['rel_sum'].each do |firstDegreePerson2|
      #check that relationship is within the date and confidence range
      if (((firstDegreePerson2[3].to_i >= min_year) || ((firstDegreePerson2[4].to_i <= max_year)) && (firstDegreePerson2[3].to_i >= min_year)))
        if ((firstDegreePerson2[1].to_i >= min_confidence) && (firstDegreePerson2[1].to_i <= max_confidence))
			    @zeroDegreePerson2Rel[firstDegreePerson2[0]] = firstDegreePerson2[0]
        end
      end
		end
		@zeroDegreePerson1[person_id1.to_i]['rel_sum'].each do |firstDegreePerson1|
      #check that relationship is within the date and confidence range
      if (((firstDegreePerson1[3].to_i >= min_year) || ((firstDegreePerson1[4].to_i <= max_year)) && (firstDegreePerson1[3].to_i >= min_year)))
        if ((firstDegreePerson1[1].to_i >= min_confidence) && (firstDegreePerson1[1].to_i <= max_confidence))
          firstDegreePersonID1 = firstDegreePerson1[0]
          if (@zeroDegreePerson2Rel.include? firstDegreePersonID1)
          	twoPeopleRecordsForReturn.update(self.find_first_degree_for_person(firstDegreePersonID1, min_confidence, max_confidence, min_year, max_year, true))
          end
        end
      end
    end
		@zeroDegreePerson1Rel = {}
		@zeroDegreePerson1Rel[person_id1] = person_id1
		@zeroDegreePerson1[person_id1.to_i]['rel_sum'].each do |firstDegreePerson1|
      if (((firstDegreePerson1[3].to_i >= min_year) || ((firstDegreePerson1[4].to_i <= max_year)) && (firstDegreePerson1[3].to_i >= min_year)))
        if ((firstDegreePerson1[1].to_i >= min_confidence) && (firstDegreePerson1[1].to_i <= max_confidence))
			    @zeroDegreePerson1Rel[firstDegreePerson1[0]] = firstDegreePerson1[0]
        end
      end
		end
		@zeroDegreePerson2[person_id2.to_i]['rel_sum'].each do |firstDegreePerson2|
      if (((firstDegreePerson2[3].to_i >= min_year) || ((firstDegreePerson2[4].to_i <= max_year)) && (firstDegreePerson2[3].to_i >= min_year)))
        if ((firstDegreePerson2[1].to_i >= min_confidence) && (firstDegreePerson2[1].to_i <= max_confidence))
          firstDegreePersonID2 = firstDegreePerson2[0]
          if (@zeroDegreePerson1Rel.include? firstDegreePersonID2)
          	twoPeopleRecordsForReturn.update(self.find_first_degree_for_person(firstDegreePersonID2, min_confidence, max_confidence, min_year, max_year, true))
          end
        end
      end
    end
    twoPeopleRecordsForReturn.update(@zeroDegreePerson1)
    twoPeopleRecordsForReturn.update(@zeroDegreePerson2)
    return twoPeopleRecordsForReturn
  end	

  #-----------------------------------------------------------------------------
  def self.all_members_of_1_group(groupID)
    peopleRecordsForReturn = {}
    #find all members of the first group
    peopleInGroup1 = Person.all_members_of_a_group(groupID)
    peopleInGroup1.each do |memberRecord|
      peopleRecordsForReturn[memberRecord.id] = memberRecord
    end
    return peopleRecordsForReturn
  end

  #this is a scope for the shared group, meaning that people that this returns are in two groups
  #-----------------------------------------------------------------------------
  def self.all_members_of_2_groups(group1ID, group2ID)
    peopleRecordsForReturn = {}
    #find all members of the first group
    peopleInGroup1 = Person.all_members_of_a_group(group1ID)
    #find all members of the second group and get their list of IDs
    idsForPeopleInGroup2 = Person.all_members_of_a_group(group2ID).map { |a| a.id }
    #loop through all members of the first group and if their id are in the list of 
    #ids for people in the second group then add them to the return array
    peopleInGroup1.each do |memberRecord|
      if (idsForPeopleInGroup2.include?(memberRecord.id))
        peopleRecordsForReturn[memberRecord.id] = memberRecord
      end
    end
    return peopleRecordsForReturn
  end

  #-----------------------------------------------------------------------------
  def init_rel_sum_and_group_list
    self.rel_sum = nil
    self.group_list = nil
  end

  #-----------------------------------------------------------------------------
  def autocomplete_name
    "#{self.display_name} (#{self.ext_birth_year})"
  end

  #-----------------------------------------------------------------------------
  def get_person_name
    # TODO: Validate that this is semantically identical to the code below.
    #return  [prefix, first_name, last_name, suffix, title].compact.join(" ")

    person_name = ""
    if (!prefix.blank?)
      person_name += prefix
    end
    if (!first_name.blank?)
      if (person_name == "")
        person_name += first_name
      else
        person_name += " " + first_name
      end
    end
    if (!last_name.blank?)
      if (person_name == "")
        person_name += last_name
      else
        person_name += " " + last_name
      end
    end
    if (!suffix.blank?)
      if (person_name == "")
        person_name += suffix
      else
        person_name += " " + suffix
      end
    end
    if (!title.blank?)
      if (person_name == "")
        person_name += title
      else
        person_name += " " + title
      end
    end
      
    return person_name
  end

  # searches for people by name
  #-----------------------------------------------------------------------------
  def self.search_approved(search)
    if search 
      return Person.all_approved.for_id(search.to_i)
    end
  end

  # searches for people by name
  #-----------------------------------------------------------------------------
  def self.search_all(search)
    if search 
      return Person.all.for_id(search.to_i)
    end
  end
end

