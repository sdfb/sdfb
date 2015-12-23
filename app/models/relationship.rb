class Relationship < ActiveRecord::Base
  attr_accessible :max_certainty, :created_by, :original_certainty, :person1_index, :person2_index,
  :justification, :approved_by, :approved_on, :created_at, :edge_birthdate_certainty,
  :is_approved, :start_year, :start_month, :start_day, :end_year, :end_month, :end_day,
  :is_active, :is_rejected, :person1_autocomplete, :person2_autocomplete,
  :start_date_type, :end_date_type, :type_certainty_list, :last_edit
  # The type certainty list is a 2d array that includes the relationship type id in the 0 index, 
  #  ...the average certainty of all relationship assignments with that relationship type, and the relationship type name
  serialize :type_certainty_list,Array
  serialize :last_edit,Array

  # Relationships
  # -----------------------------
  belongs_to :user
  # if a relationship is deleted then all associated relationship type assignments are deleted
  has_many :user_rel_contribs, :dependent => :destroy
  belongs_to :person

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

	# Validations
	# -----------------------------
	# Validates that a person cannot have a relationship with themselves
 	validate :check_if_valid, on: :create
  validates_presence_of :person1_index
  validates_presence_of :person2_index
  validates_presence_of :original_certainty
  validates_presence_of :created_by
  ## justification must be at least 4 characters
  validates_length_of :justification, :minimum => 4, on: :create, :if => :just_present?
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?
  # custom validation that checks that start year and end years
  validate :create_check_start_and_end_date

  # Scope
  # ----------------------------- 
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_active_unrejected,  -> { where(is_active: true, is_rejected: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_no_dates, -> { where("start_year IS NULL or end_year IS NULL") }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :highest_certainty, -> { order(max_certainty: :desc) }
  scope :all_for_person, -> (personID) {
      select('relationships.*')
      .where('(person1_index = ?) or (person2_index = ?)', personID, personID)}
  scope :for_2_people, -> (person1ID, person2ID) {
    select('relationships.*')
    .where('((person1_index = ?) or (person2_index = ?)) and ((person1_index = ?) or (person2_index = ?))', person1ID, person1ID, person2ID, person2ID)}
  scope :for_rels_100000000_100020000, -> { where("id between 100000000 and 100020000") }
  scope :for_rels_100020001_100040000, -> { where("id between 100020001 and 100040000") }
  scope :for_rels_100040001_100060000, -> { where("id between 100040001 and 100060000") }
  scope :for_rels_100060001_100080000, -> { where("id between 100060001 and 100080000") }
  scope :for_rels_100080001_100100000, -> { where("id between 100080001 and 100100000") }
  scope :for_rels_100100001_100120000, -> { where("id between 100100001 and 100120000") }
  scope :for_rels_100120001_100140000, -> { where("id between 100120001 and 100140000") }
  scope :for_rels_100140001_100160000, -> { where("id between 100140001 and 100160000") }
  scope :for_rels_100160001_100180000, -> { where("id between 100160001 and 100180000") }
  scope :for_rels_greater_than_100180000, -> { where("id > 100180000") }
  scope :all_recent, -> { order(updated_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }

  # Callbacks
  # -----------------------------
  before_create :init_array 
  before_create :create_check_start_and_end_date
  before_create :check_if_approved
  before_create :check_if_valid
  before_create :create_max_certainty_type_list

  before_update :update_type_list_max_certainty_on_rel
  before_update :create_check_start_and_end_date
  before_update :update_peoples_rel_sum
  before_update :check_if_approved_and_update_edit

  after_create :create_met_record
  after_create :create_peoples_rel_sum
  after_update :edit_met_record
  after_destroy :delete_from_rel_sum

	# Custom Methods
  # -----------------------------

  # delete the relationships from the rel sums of people 1 and people 2
  def delete_from_rel_sum
    rel_sum_person_1 = Person.find(self.person1_index).rel_sum
    rel_sum_person_2 = Person.find(self.person2_index).rel_sum

    # locate the record for the specific relationship for person 1
    rel_sum_person_1.each_with_index do |rel, i|
      # if you find the record then delete it
      if rel[2] == self.id
        rel_sum_person_1.delete_at(i)
      end
    end
    Person.update(self.person1_index, rel_sum: rel_sum_person_1)
    rel_sum_person_2.each_with_index do |rel, i|
      # if you find the record then delete it
      if rel[2] == self.id
        rel_sum_person_2.delete_at(i)
      end
    end
    Person.update(self.person2_index, rel_sum: rel_sum_person_2)
  end

  def init_array
    self.last_edit = nil
  end

  def create_met_record
    new_met_record = UserRelContrib.new do |u| 
      u.relationship_id = self.id
      # only set to automatically approved if the original relationship is approved, otherwise needs admin approval
      u.is_approved = true
      u.is_rejected = false
      u.is_active = true
      u.is_locked = true
      u.relationship_type_id = 4
      u.certainty = self.original_certainty
      u.created_by = 3
      u.annotation = "This record was automatically generated when the relationship was created."
      u.approved_by = 3
      u.approved_on = Time.now
      u.save!
    end
  end

  def create_max_certainty_type_list
    self.max_certainty = self.original_certainty

    # # find averages by relationship type
    # averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.id)

    # # update the certainty list with the new array of all averages by relationship type
    # # create the array includes the relationship type id, the average certainty for that relationship type, and the relationship type name
    # averages_by_rel_type_array = averages_by_rel_type.map { |e| [e.relationship_type_id, e.avg_certainty.to_f, RelationshipType.find(e.relationship_type_id).name] }

    # # update the relationships certainty list and max certainty
    # self.type_certainty_list = averages_by_rel_type_array
    averages_by_rel_type = []
    new_rel_type_record = []
    new_rel_type_record.push(4)
    new_rel_type_record.push(self.original_certainty.to_f)
    new_rel_type_record.push("Met")
    averages_by_rel_type.push(new_rel_type_record)
    self.type_certainty_list = averages_by_rel_type
  end

  def edit_met_record
    met_record = UserRelContrib.all_for_relationship(self.id).is_locked.first

    if ! met_record.nil?
      if (met_record.certainty != self.original_certainty)
        UserRelContrib.update(met_record.id, certainty: self.original_certainty)
      end
    end
  end

  ## if a user submits a new relationship but does not include a start and end date it defaults to a start and end date based on the birth years of the people in the relationship
  ## This method also checks if the start and end date are within the defined min or max years 
  ## If the relationship is not within the min and max years, the record will only be accepted if the people in the relationship are alive at that time
  def create_check_start_and_end_date
    # define defaults
    min_year = 1500
    max_year = 1700
    # stores whether the there are local variables for the people birth and death years
    retrieved_birth_death_year_flag = false
    # stores whether the max birth year and min death year were created to avoid duplicate calculations
    calculated_max_birth_min_death_year_flag = false

    # first get people's birth and death years
    if ((self.start_year.blank?) || (self.end_year.blank?))
      person1_record = Person.find(self.person1_index)
      person2_record = Person.find(self.person2_index)
      if (! person1_record.nil?)
        birth_year_1 = person1_record.ext_birth_year
        death_year_1 = person1_record.ext_death_year
      end
      if (! person2_record.nil?)
        birth_year_2 = person2_record.ext_birth_year
        death_year_2 = person2_record.ext_death_year
      end
      retrieved_birth_death_year_flag = true
    end

    #Only use default start date if the user does not enter a start year
    if (self.start_year.blank?)
      #decide new relationship start date
      if ((! birth_year_1.blank?) || (! birth_year_2.blank?))
        ##if there is a birthdate for at least 1 person
        new_start_year_type = "AF/IN"
        if ((! birth_year_1.blank?) && (! birth_year_2.blank?))
          ## Use max birth year if birthdates are recorded for both people because the relationship can't start before someone is born
          if birth_year_1 > birth_year_2
            new_start_year = birth_year_1.to_i
          else
            new_start_year = birth_year_2.to_i
          end
        elsif (! birth_year_1.blank?)
          new_start_year = birth_year_1.to_i
        elsif (! birth_year_2.blank?)
          new_start_year = birth_year_2.to_i
        end
      else
        ##if there is no birthdates, set start date to the default after or in the min year
        new_start_year_type = "AF/IN"
        new_start_year = min_year
      end
      self.start_year = new_start_year
      self.start_date_type = new_start_year_type
    else 
      #if there are existing dates, check them

      #first make sure that the end year comes before the start year, assuming end year already exists
      if ((! self.end_year.blank?) && (self.start_year.to_i > self.end_year.to_i))
        errors.add(:start_year, "The start year must be less than or equal to the end year")
        errors.add(:end_year, "The end year must be greater than or equal to the start year")
      else
        # if start year is outside of the date range, check that there is 
        # at least one person in the relationship that has a birth/death year outside of the range
        # of else throw error message
        if (self.start_year.to_i < min_year) || (self.start_year.to_i > max_year)
          # check that the birth and death years were retrieved from the people or else retrieve them for comparisons
          if retrieved_birth_death_year_flag == false
            person1_record = Person.find(self.person1_index)
            person2_record = Person.find(self.person2_index)
            if (! person1_record.nil?)
              birth_year_1 = person1_record.ext_birth_year
              death_year_1 = person1_record.ext_death_year
            end
            if (! person2_record.nil?)
              birth_year_2 = person2_record.ext_birth_year
              death_year_2 = person2_record.ext_death_year
            end
            retrieved_birth_death_year_flag = true
          end

          #calculate the min both year of both people and the max birth year
          if birth_year_1.to_i > birth_year_2.to_i
            max_birth_year = birth_year_1.to_i
          else 
            max_birth_year = birth_year_2.to_i
          end
          if death_year_1.to_i < death_year_2.to_i
            min_death_year = death_year_1.to_i
          else 
            min_death_year = death_year_2.to_i
          end
          calculated_max_birth_min_death_year_flag = true

          # if the user entered start year is outside of the person's birth year then throw and error and reject the new relationship or edit
          if (self.start_year < max_birth_year) || (self.start_year > min_death_year)
            errors.add(:start_year, "The start year must be between #{min_year} and #{max_year} or between #{max_birth_year} (after the people were born) and #{min_death_year} (before the people died) ") 
          end
        end
      end
    end 

    #Only use default end date if the user does not enter a end year
    if (self.end_year.blank?)
      #decide new relationship end date
      if ((! death_year_1.blank?) || (! death_year_2.blank?))
        ##if there is a deathdate for at least 1 person
        new_end_year_type = "BF/IN"
        if ((! death_year_1.blank?) && (! death_year_2.blank?))
          ## Use min death year if deathdates are recorded for both people because the relationship can't start before someone is born
          if death_year_1 < death_year_2
            new_end_year = death_year_1.to_i
          else
            new_end_year = death_year_2.to_i
          end
        elsif (! death_year_1.blank?)
          new_end_year = death_year_1.to_i
        elsif (! death_year_2.blank?)
          new_end_year = death_year_2.to_i
        end
      else
        ##if there is no deathdates, set end date to the default before or in the max year
        new_end_year_type = "BF/IN"
        new_end_year = max_year
      end
      self.end_year = new_end_year
      self.end_date_type = new_end_year_type
    else 
      #if there are existing dates, check them


      #first make sure that the end year comes after the start year
      if self.end_year.to_i < self.start_year.to_i
        errors.add(:start_year, "The start year must be less than or equal to the end year")
        errors.add(:end_year, "The end year must be greater than or equal to the start year")
      else
        # if end year is outside of the date range, check that there is 
        # at least one person in the relationship that has a death/death year outside of the range
        # of else throw error message
        #if (self.end_year.to_i < min_year) || (self.end_year.to_i > max_year)
          # check that the death and death years were retrieved from the people or else retrieve them for comparisons
        #  if retrieved_death_death_year_flag == false
        #    person1_record = Person.find(self.person1_index)
        #    person2_record = Person.find(self.person2_index)
        #    if (! person1_record.nil?)
        #      death_year_1 = person1_record.ext_death_year
        #    end
        #    if (! person2_record.nil?)
        #      death_year_2 = person2_record.ext_death_year
        #    end
        #    retrieved_death_death_year_flag = true
        #  end

          # the if statement checks if these values were already calculated to avoid duplicate checks
        #  if calculated_max_death_min_death_year_flag == false
            #calculate the min both year of both people and the max birth year
        #    if birth_year_1.to_i > birth_year_2.to_i
        #      max_birth_year = birth_year_1.to_i
        #    else 
        #      max_birth_year = birth_year_2.to_i
        #    end
        #    if death_year_1.to_i < death_year_2.to_i
        #      min_death_year = death_year_1.to_i
        #    else 
        #      min_death_year = death_year_2.to_i
        #    end
        #    calculated_max_birth_min_death_year_flag = true
        #  end

          # if the user entered end year outside of the range and also outside of the person's death year then throw and error and reject the new relationship or edit
        #  if (self.end_year < max_death_year) || (self.end_year > min_death_year)
        #    errors.add(:end_year, "The end year must be between #{min_year} and #{max_year} or between #{max_birth_year} (after the people were born) and #{min_death_year} (before the people died) ") 
        #  end
        # end
      end
    end 
      
  end


  def update_type_list_max_certainty_on_rel
    #only update the approved and edit status if it is not a system callback
    #a system callback can be detected because it's self.approved_by is 0 or nil
    if (self.approved_by.to_i != 0)
      # find averages by relationship type
      averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.id)

      if averages_by_rel_type.empty? 
        new_met_record = UserRelContrib.new do |u| 
          u.relationship_id = self.id
          u.is_approved = true
          u.is_rejected = false
          u.is_active = true
          u.is_locked = true
          u.relationship_type_id = 4
          u.certainty = self.original_certainty
          u.created_by = 3
          u.annotation = "This record was automatically generated when the relationship was created."
          u.approved_by = 3
          u.approved_on = Time.now
          u.save!
        end
        averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.id)
      end
      # update the certainty list with the new array of all averages by relationship type
      # create the array includes the relationship type id, the average certainty for that relationship type, and the relationship type name
      averages_by_rel_type_array = averages_by_rel_type.map { |e| [e.relationship_type_id, e.avg_certainty.to_f, RelationshipType.find(e.relationship_type_id).name] }

      # calculate the relationship's maximum certainty
      new_max_certainty = averages_by_rel_type.map { |e| e.avg_certainty.to_f }.max 
      
      # update the relationships certainty list and max certainty
      self.type_certainty_list = averages_by_rel_type_array
      self.max_certainty = new_max_certainty
      
      # update the max certainty of the relationship in the people's rel_sum
      # find the existing rel_sums for person 1 and person 2
      person1_id = self.person1_index
      rel_sum_person_1 = Person.find(person1_id).rel_sum

      person2_id = self.person2_index
      rel_sum_person_2 = Person.find(person2_id).rel_sum

      # locate the record for the specific relationship for person 1
      rel_sum_person_1.each do |rel|
        if rel[2] == self.id
          rel[1] = new_max_certainty
        end
      end
      Person.update(person1_id, rel_sum: rel_sum_person_1)
      rel_sum_person_2.each do |rel|
        if rel[2] == self.id
          rel[1] = new_max_certainty
        end
      end
      Person.update(person2_id, rel_sum: rel_sum_person_2)
    end
  end
  
  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  def get_both_names
    return Person.find(person1_index).display_name + " & " + Person.find(person2_index).display_name 
  end

  def get_person1_name
    return Person.find(person1_index).display_name 
  end

  def get_person2_name
    return Person.find(person2_index).display_name 
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end

  def just_present?
    !justification.nil?
  end

  def check_if_approved
    if (self.is_approved != true)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_and_update_edit
    #only update the approved and edit status if it is not a system callback
    #a system callback can be detected because it's self.approved_by is 0 or nil
    if (self.approved_by.to_i != 0)
      new_last_edit = []
      new_last_edit.push(self.approved_by.to_i)
      new_last_edit.push(Time.now)
      self.last_edit = new_last_edit

      # update approval
      if (self.is_approved == true)
        self.approved_on = Time.now
      else
        self.approved_by = nil
        self.approved_on = nil
      end
    end
  end

  # Validation method to check that one person is not in a relationship with themselves
  # Validation to check if the relationship already exists
  def check_if_valid
    errors.add(:person2_index, "A person cannot have a relationship with his or herself.") if person1_index == person2_index
    errors.add(:person2_index, "This relationship already exists") if (! Relationship.for_2_people(self.person1_index, self.person2_index).empty?)
  end

  # Whenever a relationship is created, the relationship summary (rel_sum) must be updated in both people's records
  def create_peoples_rel_sum
    if (self.is_approved == true)
      # update people rel sum
      person1_index_in = self.person1_index
      person2_index_in = self.person2_index
      max_certainty_in = self.original_certainty
      start_date_in = self.start_year
      end_date_in = self.end_year
      id_in = self.id

      new_rel_record = []
      new_rel_record.push(person2_index)
      new_rel_record.push(max_certainty)
      new_rel_record.push(id_in)
      new_rel_record.push(start_date_in)
      new_rel_record.push(end_date_in)
      person1_current_rel_sum = Person.find(person1_index_in).rel_sum
      person1_current_rel_sum.push(new_rel_record)
      Person.update(person1_index, rel_sum: person1_current_rel_sum)

      new_rel_record[0] = person1_index
      person2_current_rel_sum = Person.find(person2_index_in).rel_sum
      person2_current_rel_sum.push(new_rel_record)
      Person.update(person2_index, rel_sum: person2_current_rel_sum)
    end
  end

  # Whenever a relationship is updated, the relationship summary (rel_sum) must be updated in both people's records
  def update_peoples_rel_sum
    #only update the approved and edit status if it is not a system callback
    #a system callback can be detected because it's self.approved_by is 0 or nil
    if (self.approved_by.to_i != 0)
      # update people_rel_sum
      person1_index_in = self.person1_index
      person2_index_in = self.person2_index
      max_certainty_in = self.max_certainty
      start_date_in = self.start_year
      end_date_in = self.end_year
      id_in = self.id

      # For person1, find the existing rel_sum record and update it
      person1_current_rel_sum = Person.find(person1_index_in).rel_sum
      # Checks to see if the original rel_sum record existed
      person1_updated_flag = false
      person1_current_rel_sum.each_with_index do |rel_record_1, i|
        #if the rel_sum record exists, then check if approved
        if rel_record_1[0] == person2_index_in
          if self.is_approved == true     
            # if approved update record
            rel_record_1[1] = max_certainty_in
            rel_record_1[2] = id_in
            rel_record_1[3] = start_date_in
            rel_record_1[4] = end_date_in
            person1_updated_flag = true
          else
            # if not approved delete the rel_sum record
            person1_current_rel_sum.delete_at(i)
            person1_updated_flag = true
          end
        end
      end

      # if the original rel_sum record didn't exist, then make it
      if person1_updated_flag == false
        if self.is_approved == true
          new_rel_record = []
          new_rel_record.push(person2_index_in)
          new_rel_record.push(max_certainty_in)
          new_rel_record.push(id_in)
          new_rel_record.push(start_date_in)
          new_rel_record.push(end_date_in)
          person1_current_rel_sum.push(new_rel_record)
        end
      end
      Person.update(person1_index, rel_sum: person1_current_rel_sum)

      # For person2, find the existing rel_sum record and update it
      person2_current_rel_sum = Person.find(person2_index_in).rel_sum

      # Checks to see if the original rel_sum record existed
      person2_updated_flag = false
      person2_current_rel_sum.each_with_index do |rel_record_2, i|
        if rel_record_2[0] == person1_index_in
          if self.is_approved == true  
            rel_record_2[1] = max_certainty_in
            rel_record_2[2] = id_in
            rel_record_2[3] = start_date_in
            rel_record_2[4] = end_date_in
            person2_updated_flag = true
          else
            # delete the record
            person2_current_rel_sum.delete_at(i)
            person2_updated_flag = true
          end
        end
      end

      # if the original rel_sum record didn't exist, them make it
      if person2_updated_flag == false
        if self.is_approved == true
          new_rel_record = []
          new_rel_record.push(person1_index_in)
          new_rel_record.push(max_certainty_in)
          new_rel_record.push(id_in)
          new_rel_record.push(start_date_in)
          new_rel_record.push(end_date_in)
          person2_current_rel_sum.push(new_rel_record)
        end
      end
      Person.update(person2_index, rel_sum: person2_current_rel_sum)
    end
  end



  # searches for people by name
  def self.search_approved(person1Query, person2Query)
    if person1Query && person2Query
      Relationship.all_approved.for_2_people(person1Query.to_i, person2Query.to_i)
    end
  end

  # searches for people by name
  def self.search_all(person1Query, person2Query)
    if person1Query && person2Query
      Relationship.all.for_2_people(person1Query.to_i, person2Query.to_i)
    end
  end
end
