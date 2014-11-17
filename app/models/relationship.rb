class Relationship < ActiveRecord::Base
  attr_accessible :max_certainty, :created_by, :original_certainty, :person1_index, :person2_index,
  :start_date, :end_date, :justification, :approved_by, :approved_on, :created_at

  # Relationships
  # -----------------------------
  belongs_to :user
  has_many :user_rel_contribs

	# Validations
	# -----------------------------
	# Validates that a person cannot have a relationship with themselves
 	validate :check_two_different_people
  validates_presence_of :person1_index
  validates_presence_of :person2_index
  validates_presence_of :max_certainty
  validates_presence_of :original_certainty
  validates_presence_of :created_by
  validates_presence_of :approved_by
  validates_presence_of :approved_on
  ## approved_on must occur on the same date or after the created at date
  validates_date :approved_on, :on_or_after => :created_at, :message => "This relationship must be approved on or after the date it was created."
  ## max_certainty is less than or equal to one
  validates_numericality_of :max_certainty, :less_than_or_equal_to => 1
  ## justification must be at least 4 characters
  validates_length_of :justification, :minimum => 4, :if => :just_present?


  # Scope
  # ----------------------------- 
  scope :all_approved, where("approved_by is not null")
  scope :all_for_person, lambda {|person_index_input| find_by_sql("SELECT relationships.id FROM relationships
  where person1_index = #{person_index_input} OR person2_index = #{person_index_input}")}

  # Callbacks
  # ----------------------------- 
  before_create :create_peoples_rel_sum
  before_update :update_peoples_rel_sum
  after_destroy :delete_peoples_rel_sum

	# Custom Methods
	# -----------------------------
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

  # Validation method to check that one person is not in a relationship with themselves
  def check_two_different_people
    errors.add(:person2_index, "A person cannot have a relationship with his or herself.") if person1_index == person2_index
  end

  # Whenever a relationship is created, the relationship summary (rel_sum) must be updated in both people's records
  def create_peoples_rel_sum
    person1_index_in = self.person1_index
    person2_index_in = self.person2_index
    max_certainty_in = self.max_certainty
    if ! approved_by.nil?
      is_approved_in = 1
    else
      is_approved_in = 0
    end
    new_rel_record = []
    new_rel_record.push(person2_index)
    new_rel_record.push(max_certainty)
    new_rel_record.push(is_approved_in)
    person1_current_rel_sum = Person.find(person1_index_in).rel_sum
    person1_current_rel_sum.push(new_rel_record)
    Person.update(person1_index, rel_sum: person1_current_rel_sum)

    new_rel_record[0] = person1_index
    person2_current_rel_sum = Person.find(person2_index_in).rel_sum
    person2_current_rel_sum.push(new_rel_record)
    Person.update(person2_index, rel_sum: person2_current_rel_sum)
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
    if ! approved_by.nil?
      is_approved_in = 1
    else
      is_approved_in = 0
    end

    # For person2, find the existing rel_sum record and update it
    person1_current_rel_sum = Person.find(person1_index_in).rel_sum
    # Checks to see if the original rel_sum record existed
    person1_updated_flag = false
    person1_current_rel_sum.each do |rel_record_1|
      if rel_record_1[0] == person2_index_in
        rel_record_1[1] = max_certainty_in
        rel_record_1[2] = is_approved_in
        person1_updated_flag = true
      end
    end

    # if the original rel_sum record didn't exist, them make it
    if person1_updated_flag == false
      new_rel_record = []
      new_rel_record.push(person2_index_in)
      new_rel_record.push(max_certainty_in)
      new_rel_record.push(is_approved_in)
      person1_current_rel_sum.push(new_rel_record)
    end
    Person.update(person1_index, rel_sum: person1_current_rel_sum)

    # For person2, find the existing rel_sum record and update it
    person2_current_rel_sum = Person.find(person2_index_in).rel_sum
    # Checks to see if the original rel_sum record existed
    person2_updated_flag = false
    person2_current_rel_sum.each do |rel_record_2|
      if rel_record_2[0] == person1_index_in
        rel_record_2[1] = max_certainty_in
        rel_record_2[2] = is_approved_in
        person2_updated_flag = true
      end
    end

    # if the original rel_sum record didn't exist, them make it
    if person2_updated_flag == false
      new_rel_record = []
      new_rel_record.push(person1_index_in)
      new_rel_record.push(max_certainty_in)
      new_rel_record.push(is_approved_in)
      person2_current_rel_sum.push(new_rel_record)
    end
    Person.update(person2_index, rel_sum: person2_current_rel_sum)
  end
end
