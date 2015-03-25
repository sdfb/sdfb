class UserRelContrib < ActiveRecord::Base
  attr_accessible :annotation, :bibliography, :certainty, :created_by, :relationship_id, :relationship_type_id, 
  :approved_by, :approved_on, :created_at, :is_approved, :start_year, :start_month, 
  :start_day, :end_year, :end_month, :end_day, :is_active, :is_rejected, :edited_by_on, :person1_autocomplete,
  :person2_autocomplete, :person1_selection, :person2_selection, :start_date_type, :end_date_type
  serialize :edited_by_on,Array
  
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
  scope :all_approved, where("approved_by is not null and is_active is true and is_rejected is false")
  scope :all_unapproved, where("approved_by is null and is_rejected is false")
  scope :for_user, lambda {|user_input| where('created_by = ?', "#{user_input}") }
  scope :all_for_relationship, lambda {|relID| 
      select('user_rel_contribs.*')
      .where('relationship_id = ?', relID)}
  scope :highest_certainty, order('certainty DESC')

  # Callbacks
  # ----------------------------- 
  before_create :init_array
  before_create :autocomplete_to_rel
  before_update :add_editor_update_max_cert_check_approved
  before_create :update_max_certainty
  after_create :check_if_approved
  after_create :create_relationship_types_list
  after_update :create_relationship_types_list

  # Custom Methods
  # -----------------------------
  
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
          #set person1_autocomplete, person2_autocomplete, person1_selected, person2_selected to nil to save room in the database
          self.person1_autocomplete = nil
          self.person2_autocomplete = nil
          self.person1_selection = nil
          self.person2_selection = nil
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

  #this checks if the record is approved
  def check_if_approved
    if (self.is_approved == false)
      self.approved_by = nil
      self.approved_on = nil
    end  
  end

  #This creates a new relationship types list, a 2d array with each realtionship type like [type name, certainty, start_year, end_year]
  def create_relationship_types_list
    #find all approved user_rel_contribs for that relationship
    updated_rel_types_list = []
    UserRelContrib.all_approved.all_for_relationship(self.relationship_id).each do | urc |
      if ((urc.is_approved == true) && (urc.is_active == true))
        user_rel_contrib_record = []
        user_rel_contrib_record.push(RelationshipType.find(urc.relationship_type_id).name)
        user_rel_contrib_record.push(urc.certainty)
        user_rel_contrib_record.push(urc.start_year)
        user_rel_contrib_record.push(urc.end_year)
      end
      updated_rel_types_list.push(user_rel_contrib_record)
    end

    Relationship.update(self.relationship_id, types_list: updated_rel_types_list)
  end

  def add_editor_update_max_cert_check_approved
    # update edit_by_on
    if (! self.edited_by_on.blank?)
      previous_edited_by_on = UserRelContrib.find(self.id).edited_by_on
      if previous_edited_by_on.nil?
        previous_edited_by_on = []
      end
      newEditRecord = []
      newEditRecord.push(self.approved_by)
      newEditRecord.push(Time.now)
      previous_edited_by_on.push(newEditRecord)
      self.edited_by_on = previous_edited_by_on
    end

    #update max_certainty
    if (self.is_approved == true)
      # update the relationship's max certainty
        #set the max_certainty to the current user_rel_contrib certainty
        new_max_certainty = self.certainty
        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if urc.certainty > new_max_certainty
            new_max_certainty = urc.certainty
          end
        end

        # check if original certainty is greater than the max certainty
        original_certainty = Relationship.find(self.relationship_id).original_certainty
        if (original_certainty > new_max_certainty) 
          new_max_certainty = original_certainty
        end 

        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    else
        # update the relationship's max certainty
        new_max_certainty = 0

        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if urc.certainty > new_max_certainty
            new_max_certainty = urc.certainty
          end
        end

        # if max certainty = 0, set it to the original certainty
        original_certainty = Relationship.find(self.relationship_id).original_certainty
        if (original_certainty > new_max_certainty) 
          new_max_certainty = original_certainty
        end 
        
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    end

    #update approve_by
    if (self.is_approved == false)
      self.approved_by = nil
      self.approved_on = nil
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

  def update_max_certainty
    #update max_certainty
    if (self.is_approved == true)
      # update the relationship's max certainty
        #set the max_certainty to the current user_rel_contrib certainty
        new_max_certainty = self.certainty
        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if urc.certainty > new_max_certainty
            new_max_certainty = urc.certainty
          end
        end

        # check if original certainty is greater than the max certainty
        original_certainty = Relationship.find(self.relationship_id).original_certainty
        if (original_certainty > new_max_certainty) 
          new_max_certainty = original_certainty
        end 

        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
    else
        # update the relationship's max certainty
        new_max_certainty = 0

        # find all user_rel_contribs for a specific relationship
        all_user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(self.relationship_id)

        # for each user_rel_contrib, check if it is greater than the max certainty and set that to equal the new_max_certainty
        all_user_rel_contribs.each do |urc|
          if urc.certainty > new_max_certainty
            new_max_certainty = urc.certainty
          end
        end

        # if max certainty = 0, set it to the original certainty
        original_certainty = Relationship.find(self.relationship_id).original_certainty
        if (original_certainty > new_max_certainty) 
          new_max_certainty = original_certainty
        end 
        
        Relationship.update(self.relationship_id, max_certainty: new_max_certainty)

      # update the max certainty of the relationship in the people's rel_sum
        # find the existing rel_sums for person 1 and person 2
        person1_id = Relationship.find(self.relationship_id).person1_index
        rel_sum_person_1 = Person.find(person1_id).rel_sum

        person2_id = Relationship.find(self.relationship_id).person2_index
        rel_sum_person_2 = Person.find(person2_id).rel_sum

        # locate the record for the specific relationship for person 1
        rel_sum_person_1.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person1_id, rel_sum: rel_sum_person_1)
        rel_sum_person_2.each do |rel|
          if rel[2] == self.relationship_id
            rel[1] = new_max_certainty
          end
        end
        Person.update(person2_id, rel_sum: rel_sum_person_2)
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
end
