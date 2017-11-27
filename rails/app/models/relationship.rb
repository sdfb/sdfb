class Relationship < ActiveRecord::Base

  include Approvable
  
  attr_accessible :max_certainty, :created_by, :original_certainty, :person1_index, :person2_index,
  :justification, :created_at, :citation,
  :start_year,  :end_year, 
  :start_date_type, :end_date_type

  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :user_rel_contribs, dependent: :destroy
  belongs_to :person

	# Validations
	# -----------------------------
 	validate :check_if_valid, on: :create
  validates_presence_of :person1_index
  validates_presence_of :person2_index
  validates_presence_of :original_certainty
  validates_presence_of :created_by
  validates_length_of :justification, minimum: 4, on: :create, allow_nil: true
  validates_inclusion_of :start_date_type, in: SDFB::DATE_TYPES, if: "self.start_year.present?"
  validates_inclusion_of :end_date_type,   in: SDFB::DATE_TYPES, if: "self.end_year.present?"
  validates :start_year, numericality: { greater_than_or_equal_to: SDFB::EARLIEST_YEAR, less_than_or_equal_to: SDFB::LATEST_YEAR }, allow_nil: true
  validates :end_year,   numericality: { greater_than_or_equal_to: SDFB::EARLIEST_YEAR, less_than_or_equal_to: SDFB::LATEST_YEAR }, allow_nil: true

  # Scope
  # ----------------------------- 
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_person, -> (personID) {
      select('relationships.*')
      .where('(person1_index = ?) or (person2_index = ?)', personID, personID)}
  scope :for_2_people, -> (person1ID, person2ID) {
    select('relationships.*')
    .where('((person1_index = ?) or (person2_index = ?)) and ((person1_index = ?) or (person2_index = ?))', person1ID, person1ID, person2ID, person2ID)}

  # Callbacks
  # -----------------------------
  before_save :create_check_start_and_end_date
  before_update :update_max_certainty
  after_save    :update_met_record
  after_save    :updated_altered_state!

	# Custom Methods
  # -----------------------------

  def updated_altered_state!
    value = (created_by && created_by != 2) || user_rel_contribs.where("created_by != ?",3).count > 0
    update_column(:altered, value)
  end

  # -----------------------------
  def update_met_record
    met_record = UserRelContrib.where(relationship_type_id: 4,
                                      relationship_id: self.id)
                               .first_or_create!(
                                   relationship_id: self.id,
                                   is_approved: self.is_approved,
                                   is_active: true,
                                   relationship_type_id: 4,
                                   created_by: 3,
                                   certainty: self.original_certainty
                              )

    met_record.update_attributes(certainty: self.original_certainty,
                                 start_year: self.start_year,
                                 end_year: self.end_year
    )

    met_record.save
  end


  ## if a user submits a new relationship but does not include a start and end date it defaults to a start and end date based on the birth years of the people in the relationship
  ## This method also checks if the start and end date are within the defined min or max years 
  ## If the relationship is not within the min and max years, the record will only be accepted if the people in the relationship are alive at that time
  # -----------------------------
  def create_check_start_and_end_date

    # stores whether the there are local variables for the people birth and death years
    retrieved_birth_death_year_flag = false
    # stores whether the max birth year and min death year were created to avoid duplicate calculations
    calculated_max_birth_min_death_year_flag = false

    # first get people's birth and death years
    if ((self.start_year.blank?) || (self.end_year.blank?))
      person1_record = Person.find(self.person1_index)
      person2_record = Person.find(self.person2_index)
      if (! person1_record.nil?)
        birth_year_1 = person1_record.birth_year
        death_year_1 = person1_record.death_year
      end
      if (! person2_record.nil?)
        birth_year_2 = person2_record.birth_year
        death_year_2 = person2_record.death_year
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
        new_start_year = SDFB::EARLIEST_YEAR
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
        if (self.start_year.to_i < SDFB::EARLIEST_YEAR) || (self.start_year.to_i > SDFB::LATEST_YEAR)
          # check that the birth and death years were retrieved from the people or else retrieve them for comparisons
          if retrieved_birth_death_year_flag == false
            person1_record = Person.find(self.person1_index)
            person2_record = Person.find(self.person2_index)
            if (! person1_record.nil?)
              birth_year_1 = person1_record.birth_year
              death_year_1 = person1_record.death_year
            end
            if (! person2_record.nil?)
              birth_year_2 = person2_record.birth_year
              death_year_2 = person2_record.death_year
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
            errors.add(:start_year, "The start year must be between #{SDFB::EARLIEST_YEAR} and #{SDFB::LATEST_YEAR} or between #{max_birth_year} (after the people were born) and #{min_death_year} (before the people died) ") 
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
        new_end_year = SDFB::LATEST_YEAR
      end
      self.end_year = new_end_year
      self.end_date_type = new_end_year_type
    else 
      #if there are existing dates, check them


      #first make sure that the end year comes after the start year
      if self.end_year.to_i < self.start_year.to_i
        errors.add(:start_year, "The start year must be less than or equal to the end year")
        errors.add(:end_year, "The end year must be greater than or equal to the start year")
      end
    end 
      
  end


  # -----------------------------
  def update_max_certainty
    #only update the approved and edit status if it is not a system callback
    #a system callback can be detected because it's self.approved_by is 0 or nil
    if (self.approved_by.to_i != 0)
      # find averages by relationship type
      averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.id)

      if averages_by_rel_type.empty? 
        new_met_record = UserRelContrib.new do |u| 
          u.relationship_id = self.id
          u.is_approved = true
          u.is_active = true
          u.relationship_type_id = 4
          u.certainty = self.original_certainty
          u.created_by = 3
          u.approved_by = 3
          u.approved_on = Time.now
          u.save!
        end
        averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.id)
      end

      # calculate the relationship's maximum certainty
      new_max_certainty = averages_by_rel_type.map { |e| e.avg_certainty.to_f }.max 
      
      # update the max certainty
      self.max_certainty = new_max_certainty
    end
  end
  
  # -----------------------------
  def get_both_names
    return Person.find(person1_index).display_name + " & " + Person.find(person2_index).display_name 
  end

  # Validation method to check that one person is not in a relationship with themselves
  # Validation to check if the relationship already exists
  # -----------------------------
  def check_if_valid
    errors.add(:person2_index, "A person cannot have a relationship with his or herself.") if person1_index == person2_index
    errors.add(:person2_index, "This relationship already exists") if (! Relationship.for_2_people(self.person1_index, self.person2_index).empty?)
  end

end
