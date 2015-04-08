class Relationship < ActiveRecord::Base
  attr_accessible :max_certainty, :created_by, :original_certainty, :person1_index, :person2_index,
  :justification, :approved_by, :approved_on, :created_at, :edge_birthdate_certainty,
  :is_approved, :start_year, :start_month, :start_day, :end_year, :end_month, :end_day,
  :is_active, :is_rejected, :edited_by_on, :person1_autocomplete, :person2_autocomplete, :types_list,
  :start_date_type, :end_date_type
  serialize :edited_by_on,Array
  serialize :types_list,Array

  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :user_rel_contribs

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

	# Validations
	# -----------------------------
	# Validates that a person cannot have a relationship with themselves
 	validate :check_if_valid, on: :create
  validates_presence_of :person1_index
  validates_presence_of :person2_index
  #validates_presence_of :max_certainty
  validates_presence_of :original_certainty
  validates_presence_of :created_by
  #validates_presence_of :approved_by
  #validates_presence_of :approved_on
  ## approved_on must occur on the same date or after the created at date
  #validates_date :approved_on, :on_or_after => :created_at, :message => "This relationship must be approved on or after the date it was created."
  ## max_certainty is less than or equal to one
  #validates_numericality_of :max_certainty, :less_than_or_equal_to => 1
  ## justification must be at least 4 characters
  validates_length_of :justification, :minimum => 4, on: :create, :if => :just_present?
  # edge_birthdate_certainty is one included in the list
  ##validates_inclusion_of :edge_birthdate_certainty, :in => %w(0 1 2), :allow_blank => true
  #validate :check_if_start_date_complete
  #validate :check_if_end_date_complete
  validates :start_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :start_year_present?
  validates :start_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :start_year_present?
  validates :end_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :end_year_present?
  validates :end_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :end_year_present?
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :highest_certainty, order('max_certainty DESC')
  scope :all_inactive, where("is_active is true")
  scope :all_rejected, where("is_rejected is true")
  scope :all_for_person, 
    lambda {|personID| 
      select('relationships.*')
      .where('(person1_index = ?) or (person2_index = ?)', personID, personID)}
  scope :for_2_people,
    lambda {|person1ID, person2ID| 
    select('relationships.*')
    .where('((person1_index = ?) or (person2_index = ?)) and ((person1_index = ?) or (person2_index = ?))', person1ID, person1ID, person2ID, person2ID)}
  scope :for_rels_100000000_100020000, where("id between 100000000 and 100020000")
  scope :for_rels_100020001_100040000, where("id between 100020001 and 100040000")
  scope :for_rels_100040001_100060000, where("id between 100040001 and 100060000")
  scope :for_rels_100060001_100080000, where("id between 100060001 and 100080000")
  scope :for_rels_100080001_100100000, where("id between 100080001 and 100100000")
  scope :for_rels_100100001_100120000, where("id between 100100001 and 100120000")
  scope :for_rels_100120001_100140000, where("id between 100120001 and 100140000")
  scope :for_rels_100140001_100160000, where("id between 100140001 and 100160000")
  scope :for_rels_100160001_100180000, where("id between 100160001 and 100180000")
  scope :for_rels_greater_than_100180000, where("id > 100180000")

  # Callbacks
  # ----------------------------- 
  before_create :max_certainty_on_create
  after_create :create_peoples_rel_sum
  before_create :create_start_and_end_date
  before_update :create_start_and_end_date
  after_update :update_peoples_rel_sum
  after_destroy :delete_peoples_rel_sum
  before_create :check_if_approved
  before_update :check_if_approved
  before_create :check_if_valid
  before_create :init_array
  before_update :add_editor_to_edit_by_on_max_certainty

	# Custom Methods
  # -----------------------------

  ##if a user submits a new relationship but does not include a start and end date it defaults to a start and end date based on the birth years of the people in the relationship
  def create_start_and_end_date
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
        ##if there is no birthdates, set start date to the default CA 1400 (around 1400)
        new_start_year_type = "CA"
        new_start_year = 1400
      end

      self.start_year = new_start_year
      self.start_date_type = new_start_year_type
    end 

    #Only use default end date if the user does not enter an end year
    if (self.end_year.blank?)
      #decide new relationship end date
      if ((! death_year_1.blank?) || (! death_year_2.blank?))
        ##if there is a deathdate for at least 1 person
        new_end_year_type = "BF/IN"
        if ((! death_year_1.blank?) && (! death_year_2.blank?))
          ## Use min deathdate if deathdates are recorded for both people because the relationship will end by the time of the people dies
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
        ##If there is no death year, set end year to the default CA 1800 (around 1800)
        new_end_year_type = "CA"
        new_end_year = 1800
      end
      self.end_year = new_end_year
      self.end_date_type = new_end_year_type
    end
  end

  def add_editor_to_edit_by_on_max_certainty
    #Add editor to edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = Relationship.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.edited_by_on)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end

    # update max certainty
    # Only update max_certainty if there are no User_rel_edits
    user_rel_contribs = UserRelContrib.all_for_relationship(self.id)

    if (user_rel_contribs.blank?)
      # update the relationship's max certainty
      self.max_certainty = self.original_certainty
    
      # update the max certainty of the relationship in the people's rel_sum
      # find the existing rel_sums for person 1 and person 2
      person1_id = self.person1_index
      rel_sum_person_1 = Person.find(person1_id).rel_sum

      person2_id = self.person2_index
      rel_sum_person_2 = Person.find(person2_id).rel_sum

      # locate the record for the specific relationship for person 1
      rel_sum_person_1.each do |rel|
        if rel[3] == self.id
          rel[1] = self.original_certainty
        end
      end
      Person.update(person1_id, rel_sum: rel_sum_person_1)
      rel_sum_person_2.each do |rel|
        if rel[3] == self.id
          rel[1] = self.original_certainty
        end
      end
      Person.update(person2_id, rel_sum: rel_sum_person_2)
    end
  end

  def init_array
    self.edited_by_on = nil
  end
  
  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  def max_certainty_on_create
    self.max_certainty = self.original_certainty
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
      max_certainty_in = self.max_certainty
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

  # When a relationship is deleted, it is removed from each person's relationship summary
  def delete_peoples_rel_sum
    person1_index_in = self.person1_index
    person2_index_in = self.person2_index

    # replace the person 1's current_rel_sum with a smaller rel_sum that does not have the relationship
    person1_current_rel_sum = Person.find(person1_index_in).rel_sum
    person1_current_rel_sum.each_with_index do |rel_record_1, i|
      if rel_record_1[0] == person2_index_in
        person1_current_rel_sum.delete_at(i)
        break
      end
    end
    Person.update(person1_index, rel_sum: person1_current_rel_sum)

    # replace the person 2's current_rel_sum with a smaller rel_sum that does not have the relationship
    person2_current_rel_sum = Person.find(person2_index_in).rel_sum
    person2_current_rel_sum.each_with_index do |rel_record_2, i|
      if rel_record_2[0] == person1_index_in
        person2_current_rel_sum.delete_at(i)
        break
      end
    end
    Person.update(person2_index, rel_sum: person2_current_rel_sum)
  end

  # Whenever a relationship is updated, the relationship summary (rel_sum) must be updated in both people's records
  def update_peoples_rel_sum
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
