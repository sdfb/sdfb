class UserRelContrib < ActiveRecord::Base
  # this class is known as "Relationship Type Assignment" to the user
  
  include WhitespaceStripper
  include Approvable

  attr_accessible :relationship_id, :relationship_type_id, 
  :created_by, :created_at, :is_locked,
  :start_year, :start_month, :start_day, :start_date_type,
  :end_year, :end_month, :end_day, :end_date_type,
  :annotation, :bibliography, :certainty

  # Relationships
  # -----------------------------
  belongs_to :relationship
  belongs_to :relationship_type
  belongs_to :user

  # Misc Constants
  # -----------------------------

  # Validations
  # -----------------------------
  validates_presence_of :certainty
  validates_presence_of :created_by
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type_id
  validates_length_of   :bibliography, minimum: 10, allow_blank: true
  validates :start_year, numericality: { greater_than_or_equal_to: SDFB::EARLIEST_BIRTH_YEAR, less_than_or_equal_to: SDFB::LATEST_DEATH_YEAR }, allow_nil: true
  validates :end_year,   numericality: { greater_than_or_equal_to: SDFB::EARLIEST_BIRTH_YEAR, less_than_or_equal_to: SDFB::LATEST_DEATH_YEAR }, allow_nil: true
  validates_inclusion_of :start_date_type, in: SDFB::DATE_TYPES, if: "self.start_year.present?"
  validates_inclusion_of :end_date_type, in: SDFB::DATE_TYPES, if: "self.end_year.present?"

  # Scope
  # ----------------------------- 
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_relationship, -> (relID) {
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}
  scope :highest_certainty, -> { order(certainty: :desc) }
  scope :is_locked, -> { where(is_locked: true) } 
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :all_averages_for_relationship, -> (relID) {
      select(:relationship_type_id, "AVG(certainty) as avg_certainty")
      .where('relationship_id = ?', relID)
      .group('relationship_type_id')}


  # Callbacks
  # ----------------------------- 
  before_save :create_start_and_end_date
  before_save { remove_trailing_spaces(:annotation, :bibliography)}
  after_save :update_type_list_max_certainty_on_rel
  after_create :set_approval_metadata
  after_destroy :type_list_max_cert_on_rel_on_destroy

  # Custom Methods
  # -----------------------------
  def set_approval_metadata
    if (self.is_approved == true)
      self.approved_by = "Admin"
      self.approved_on = Time.now
    end
  end

  ## if a user submits a new relationship but does not 
  ## include a start and end date it defaults to a start and end date 
  ## based on the birth years of the people in the relationship
  # -----------------------------
  def create_start_and_end_date
    person1_index = Relationship.find(relationship_id).person1_index
    person2_index = Relationship.find(relationship_id).person2_index
    person1_record = Person.find(person1_index)
    person2_record = Person.find(person2_index)
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
        ##if there is no birthdates, set start date to the default (circa SDFB::EARLIEST_BIRTH_YEAR)
        new_start_year_type = "CA"
        new_start_year = SDFB::EARLIEST_BIRTH_YEAR
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


  # update the relationship type list and the maximum certainty 
  # when the relationship type assignment is destroyed
  def type_list_max_cert_on_rel_on_destroy
    if self.is_locked != true
      # find averages by relationship type
      averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.relationship_id)

      ###If there are no rel_types that are approved, then do nothing because this is taken care of in the relationship callback

      if ! averages_by_rel_type.nil? 

        # calculate the relationship's maximum certainty
        new_max_certainty = averages_by_rel_type.map { |e| e.avg_certainty.to_f }.max 
        
        # update the relationships certainty list and max certainty
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)
        
        # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        relationship_record = Relationship.find(self.relationship_id)
        person1_id = relationship_record.person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = relationship_record.person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each_with_index do |rel, i|
          # if you find the record then delete it
          if rel[2] == relationship_record.id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each_with_index do |rel, i|
          # if you find the record then delete it
          if rel[2] == relationship_record.id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
      end
    end
  end


  # update the relationship type list and the maximum certainty
  def update_type_list_max_certainty_on_rel
    if self.is_locked != true
      # find averages by relationship type
      averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.relationship_id)

      ###If there are no rel_types that are approved, then do nothing because this is taken care of in the relationship callback

      if ! averages_by_rel_type.nil? 

        # calculate the relationship's maximum certainty
        new_max_certainty = averages_by_rel_type.map { |e| e.avg_certainty.to_f }.max 
        
        # update the relationships certainty list and max certainty
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)
        
        # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        relationship_record = Relationship.find(self.relationship_id)
        person1_id = relationship_record.person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = relationship_record.person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[2] == relationship_record.id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[2] == relationship_record.id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
      end
    end
  end

end
