class Relationship < ActiveRecord::Base
  attr_accessible :max_certainty, :created_by, :original_certainty, :person1_index, :person2_index,
  :justification, :approved_by, :approved_on, :created_at, :edge_birthdate_certainty,
  :is_approved, :start_year, :start_month, :start_day, :end_year, :end_month, :end_day

  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :user_rel_contribs

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

  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
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
  after_update :update_peoples_rel_sum
  after_destroy :delete_peoples_rel_sum
  before_create :check_if_approved
  before_update :check_if_approved
  before_create :check_if_valid
  #before_create :check_if_start_date_complete
  #before_update :check_if_start_date_complete
  #before_create :check_if_end_date_complete
  #before_update :check_if_end_date_complete

	# Custom Methods
  # -----------------------------
  # def check_if_start_date_complete
  #   if ((!((! self.start_day.blank?) && (! self.start_month.blank?) && (! self.start_year.blank?))) || (!((self.start_day.blank?) && (self.start_month.blank?) && (self.start_year.blank?))))
  #     errors.add(:start_day, "The start date is incomplete without the start day.") if self.start_day.blank?
  #     errors.add(:start_month, "The start date is incomplete without the start month.") if self.start_month.blank?
  #     errors.add(:start_year, "The start date is incomplete without the start year.") if self.start_year.blank?
  #   end
  # end

  # def check_if_end_date_complete
  #   if ((!((! self.end_day.blank?) && (! self.end_month.blank?) && (! self.end_year.blank?))) || (!((self.end_day.blank?) && (self.end_month.blank?) && (self.end_year.blank?))))
  #     errors.add(:end_day, "The end date is incomplete without the end day.") if self.end_day.blank?
  #     errors.add(:end_month, "The end date is incomplete without the end month.") if self.end_month.blank?
  #     errors.add(:end_year, "The end date is incomplete without the end year.") if self.end_year.blank?
  #   end
  # end
  def start_year_present?
    ! self.start_year.nil?
  end

  def end_year_present?
    ! self.end_year.nil?
  end

  def max_certainty_on_create
    self.max_certainty = self.original_certainty
  end

  def get_person1_name
    return Person.find(person1_index).first_name + " " + Person.find(person1_index).last_name 
  end

  def get_person2_name
    return Person.find(person2_index).first_name + " " + Person.find(person2_index).last_name 
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
    if (self.is_approved == true)
      self.approved_on = Time.now
    else
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
      person1_index_in = self.person1_index
      person2_index_in = self.person2_index
      max_certainty_in = self.max_certainty
      id_in = self.id
      if ! approved_by.nil?
        is_approved_in = 1
      else
        is_approved_in = 0
      end
      new_rel_record = []
      new_rel_record.push(person2_index)
      new_rel_record.push(max_certainty)
      new_rel_record.push(is_approved_in)
      new_rel_record.push(id_in)
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
    person1_index_in = self.person1_index
    person2_index_in = self.person2_index
    max_certainty_in = self.max_certainty
    id_in = self.id
    if ! approved_by.nil?
      is_approved_in = 1
    else
      is_approved_in = 0
    end

    # For person1, find the existing rel_sum record and update it
    person1_current_rel_sum = Person.find(person1_index_in).rel_sum
    # Checks to see if the original rel_sum record existed
    person1_updated_flag = false
    person1_current_rel_sum.each_with_index do |rel_record_1, i|
      #if the rel_sum record exists, then check if approved
      if rel_record_1[0] == person2_index_in
        if self.is_approved == true     
          # update record
          rel_record_1[1] = max_certainty_in
          rel_record_1[2] = is_approved_in
          rel_record_1[3] = id_in
          person1_updated_flag = true
        else
          # delete the record
          person1_current_rel_sum.delete_at(i)
          person1_updated_flag = true
        end
      end
    end

    # if the original rel_sum record didn't exist, them make it
    if person1_updated_flag == false
      if self.is_approved == true
        new_rel_record = []
        new_rel_record.push(person2_index_in)
        new_rel_record.push(max_certainty_in)
        new_rel_record.push(is_approved_in)
        new_rel_record.push(id_in)
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
          rel_record_2[2] = is_approved_in
          rel_record_2[3] = id_in
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
        new_rel_record.push(is_approved_in)
        new_rel_record.push(id_in)
        person2_current_rel_sum.push(new_rel_record)
      end
    end
    Person.update(person2_index, rel_sum: person2_current_rel_sum)
  end
end
