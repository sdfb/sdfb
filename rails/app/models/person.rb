class Person < ActiveRecord::Base
  # Misc Constants
  # -----------------------------
  GENDER_LIST    = ["female", "male", "gender_nonconforming"]

  
  include WhitespaceStripper
  include Approvable

  # TODO: Figure out if :group_list is actually used anywhere.
  # TODO: Figure out how many of these actually need to be writable.

  attr_accessible :odnb_id, 
                  :prefix, :title, :first_name, :last_name, :suffix, :display_name, :aliases, :search_names_all,
                  :historical_significance, :justification,  :gender,                
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
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }
  scope :alphabetical, -> { order(last_name: :asc, first_name: :asc) }


  # Validations
  # -----------------------------
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
  before_create  :populate_search_names
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

  #-----------------------------------------------------------------------------
  def init_rel_sum_and_group_list
    self.rel_sum = nil
    self.group_list = nil
  end

  #-----------------------------------------------------------------------------
  def get_person_name
    [prefix, first_name, last_name, suffix, title].compact.join(" ")
  end
end

