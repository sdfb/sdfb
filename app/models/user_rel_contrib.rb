class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :certainty, :created_by, :relationship_id, :relationship_type_id, 
  :approved_by, :approved_on, :created_at, :is_approved, :start_year, :start_month, 
  :start_day, :end_year, :end_month, :end_day, :is_active, :is_rejected, :person1_autocomplete,
  :person2_autocomplete, :person1_selection, :person2_selection, :start_date_type, :end_date_type, :last_edit, :is_locked
  serialize :last_edit,Array

  # Relationships
  # -----------------------------
  belongs_to :relationship
  belongs_to :relationship_type
  belongs_to :user

  # Misc Constants
  # -----------------------------
  USER_EST_CERTAINTY_LIST = ["Certain", "Highly Likely", "Possible", "Unlikely", "Very Unlikely"]

  ###need rel type for directional
  ###need inverse rel type for directional

  # Misc Constants
  DATE_TYPE_LIST = ["BF", "AF","IN","CA","BF/IN","AF/IN","NA"]

  # Validations
  # -----------------------------
  validates_presence_of :annotation
  validates_presence_of :certainty
  validates_presence_of :created_by
  validates_presence_of :relationship_id
  validates_presence_of :relationship_type_id
  ## annotation must be at least 10 characters
  validates_length_of :annotation, :minimum => 10, :if => :annot_present?
  ## bibliography must be at least 10 characters
  validates_length_of :bibliography, :minimum => 10, :if => :bib_present?
  validates :start_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :start_year_present?
  validates :start_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :start_year_present?
  validates :end_year, :numericality => { :greater_than_or_equal_to => 1400 }, :if => :end_year_present?
  validates :end_year, :numericality => { :less_than_or_equal_to => 1800 }, :if => :end_year_present?
  ## start date type is one included in the list
  validates_inclusion_of :start_date_type, :in => DATE_TYPE_LIST, :if => :start_year_present?
  ## end date type is one included in the list
  validates_inclusion_of :end_date_type, :in => DATE_TYPE_LIST, :if => :end_year_present?
  validate :autocomplete_to_rel, :on => :create

  # Scope
  # ----------------------------- 
  scope :all_approved, -> { where(is_approved: true, is_active: true, is_rejected: false) }
  scope :all_inactive, -> { where(is_active: false) }
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :all_rejected, -> { where(is_rejected: true, is_active: true) }
  scope :all_unapproved, -> { where(is_approved: false, is_rejected: false, is_active: true) }
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :all_for_relationship, -> (relID) {
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}
  scope :highest_certainty, -> { order(certainty: :desc) }
  scope :all_recent, -> { order(created_at: :desc) }
  scope :order_by_sdfb_id, -> { order(id: :asc) }
  scope :is_locked, -> { where(is_locked: true) } 
  scope :all_active_unrejected, -> { where(is_active: true, is_rejected: false) }
  scope :all_averages_for_relationship, -> (relID) {
      select(:relationship_type_id, "AVG(certainty) as avg_certainty")
      .where('relationship_id = ?', relID)
      .group('relationship_type_id')}
  ## all of these scopes are used to export specific relationship types based on the ids
  scope :for_rel_type_assigns_00000_20000, -> { where("id between 1 and 20000") }
  scope :for_rel_type_assigns_20001_40000, -> { where("id between 20001 and 40000") }
  scope :for_rel_type_assigns_40001_60000, -> { where("id between 40001 and 60000") }
  scope :for_rel_type_assigns_60001_80000, -> { where("id between 60001 and 80000") }
  scope :for_rel_type_assigns_80001_100000, -> { where("id between 80001 and 100000") }
  scope :for_rel_type_assigns_100001_120000, -> { where("id between 100001 and 120000") }
  scope :for_rel_type_assigns_120001_140000, -> { where("id between 120001 and 140000") }
  scope :for_rel_type_assigns_140001_160000, -> { where("id between 140001 and 160000") }
  scope :for_rel_type_assigns_160001_180000, -> { where("id between 160001 and 180000") }
  scope :for_rel_type_assigns_greater_than_180000, -> { where("id > 180000") }

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :autocomplete_to_rel
  before_create :auto_approve
  before_update :check_if_approved_and_update_edit
  before_create :check_if_approved
  after_create :update_type_list_max_certainty_on_rel
  after_update :update_type_list_max_certainty_on_rel
  before_create :create_start_and_end_date
  before_update :create_start_and_end_date
  before_update :remove_trailing_spaces
  before_create :remove_trailing_spaces
  after_destroy :type_list_max_cert_on_rel_on_destroy

  # Custom Methods
  # -----------------------------

  # end

  def init_array
    self.last_edit = nil
  end
  
  #This converts the person1_selected and the person2_selected into the relationship_id foreign key
  def autocomplete_to_rel
    #find the relationship_id given the two people
    if (self.relationship_id == 0)
      if ((! self.person1_selection.blank?) && (! self.person2_selection.blank?))
        found_rel_id = Relationship.for_2_people(self.person1_selection, self.person2_selection)[0]
        if (found_rel_id.nil?)
        #if the relationship does not exist, then through an error
        errors.add(:person2_autocomplete, "This relationship does not exist.")
        else
          self.relationship_id = found_rel_id.id
        end
      else
        if (self.person1_selection.blank?) 
          errors.add(:person1_autocomplete, "Please select people from the autocomplete dropdown menus.")
        end
        if (self.person2_selection.blank?) 
          errors.add(:person2_autocomplete, "Please select people from the autocomplete dropdown menus.")
        end
      end
    end
  end

# Checks if associated rel is approved, if it is -> auto approve this rel_contrib, otherwise set is_approved to false so needs admin approval
  def auto_approve 
    if self.relationship_id != nil 
      if Relationship.find(self.relationship_id).is_approved
        self.is_approved = true
      else
        self.is_approved = false
      end
    else
      # Needs admin approval
      self.is_approved = false
    end
  end

  #this checks if the record is approved
  def check_if_approved
    if (self.is_approved == false)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  def check_if_approved_and_update_edit
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

  ##if a user submits a new relationship but does not include a start and end date it defaults to a start and end date based on the birth years of the people in the relationship
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

  def update_approved
    #update approve_by
    if (self.is_approved == false)
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

  # update the relationship type list and the maximum certainty when the relationship type assignment is destroyed
  def type_list_max_cert_on_rel_on_destroy
    if self.is_locked != true
      # find averages by relationship type
      averages_by_rel_type = UserRelContrib.all_approved.all_averages_for_relationship(self.relationship_id)

      ###If there are no rel_types that are approved, then do nothing because this is taken care of in the relationship callback

      if ! averages_by_rel_type.nil? 
        # update the certainty list with the new array of all averages by relationship type
        # create the array includes the relationship type id, the average certainty for that relationship type, and the relationship type name
        averages_by_rel_type_array = averages_by_rel_type.map { |e| [e.relationship_type_id, e.avg_certainty.to_f, RelationshipType.find(e.relationship_type_id).name] }

        # calculate the relationship's maximum certainty
        new_max_certainty = averages_by_rel_type.map { |e| e.avg_certainty.to_f }.max 
        
        # update the relationships certainty list and max certainty
        Relationship.update(self.relationship_id, type_certainty_list: averages_by_rel_type_array, max_certainty: new_max_certainty)
        
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
        # update the certainty list with the new array of all averages by relationship type
        # create the array includes the relationship type id, the average certainty for that relationship type, and the relationship type name
        averages_by_rel_type_array = averages_by_rel_type.map { |e| [e.relationship_type_id, e.avg_certainty.to_f, RelationshipType.find(e.relationship_type_id).name] }

        # calculate the relationship's maximum certainty
        new_max_certainty = averages_by_rel_type.map { |e| e.avg_certainty.to_f }.max 
        
        # update the relationships certainty list and max certainty
        Relationship.update(self.relationship_id, type_certainty_list: averages_by_rel_type_array, max_certainty: new_max_certainty)
        
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

  def annot_present?
    ! self.annotation.blank?
  end

  def bib_present?
    ! self.bibliography.blank?
  end

  def get_person1_name
    return Person.find(Relationship.find(relationship_id).person1_index).display_name
  end

  def get_person2_name
    return Person.find(Relationship.find(relationship_id).person2_index).display_name
  end

  def get_both_names
    return Person.find(Relationship.find(relationship_id).person1_index).display_name + " & " + Person.find(Relationship.find(relationship_id).person2_index).display_name
  end

  def get_users_name
    if (created_by != nil)
      return User.find(created_by).first_name + " " + User.find(created_by).last_name
    else
      return "ODNB"
    end
  end

  def remove_trailing_spaces
    if ! self.annotation.nil?
      self.annotation.strip!
    end
    if ! self.bibliography.nil?
      self.bibliography.strip!
    end
  end
end
