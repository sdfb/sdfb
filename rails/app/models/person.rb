class Person < ActiveRecord::Base
  
  include WhitespaceStripper
  include Approvable

  attr_accessible :prefix, :title, :first_name, :last_name, :suffix, :gender,
                  :display_name, :aliases, :search_names_all, :odnb_id, 
                  :historical_significance, :justification, :citation,
                  :birth_year_type, :birth_year,
                  :death_year_type, :death_year,
                  :created_by, :created_at

  # Relationships
  # -----------------------------
  has_many :group_assignments, dependent: :destroy
  has_many :groups, through: :group_assignments
  belongs_to :user

  # Scope
  # ----------------------------- 
  scope :for_user, -> (user_input) { where('created_by = ?', "#{user_input}") }

  # Validations
  # -----------------------------
  validates_presence_of :created_by
  validates_presence_of :gender
  validates_presence_of :birth_year_type
  validates_presence_of :birth_year
  validates_presence_of :death_year_type
  validates_presence_of :death_year
  ## first_name must be at least 1 character
  validates_length_of :first_name, :minimum => 1, :allow_blank => true
  ## last_name must be at least 1 character
  validates_length_of :last_name, :minimum => 1, :allow_blank => true
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
  validates_inclusion_of :gender, :in => SDFB::GENDER_LIST
  # custom validation that checks the birth and death dates
  validate :check_birth_death_years

  # Callbacks
  # ----------------------------- 
  before_create  :populate_search_names
  before_save    :check_birth_death_years
  before_save    :add_display_name_if_blank
  before_destroy :delete_associated_relationships
  before_save    { remove_trailing_spaces(:prefix, :title, :first_name, :last_name, :suffix, :display_name, :aliases)}


  # Custom Methods
  # -----------------------------

  # TODO: This is now the performance bottlenext
  def approved_group_ids
    groups = self.group_assignments.to_a
    groups.map{|obj| obj.group_id if obj.is_approved}.compact
  end

  # if the display name is blank then add one
  # -----------------------------
  def add_display_name_if_blank
    if self.display_name.blank?
      new_display_name = self.get_person_name
      self.display_name = new_display_name
    end
  end

  # -----------------------------
  def relationships(certainty=SDFB::DEFAULT_CONFIDENCE)
    results = Relationship.all_approved.where("person1_index = ? OR person2_index = ?", self.id, self.id)
    results = results.where(max_certainty: (certainty..100)) if certainty > 0
    results
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
    if self.birth_year.present?
      if self.birth_year.to_i == 0
        errors.add(:birth_year, "Please check the format of the birth year.")
        invalid_birth_year_format = true
      # if valid format continue checking
      else
        # check that birth year is before SDFB::LATEST_YEAR or throw error
        if self.birth_year.to_i > SDFB::LATEST_YEAR
          errors.add(:birth_year, "The birth year must be before #{SDFB::LATEST_YEAR}")
        end
      end
    end

    # if the death year converted to an integer is 0 then the date was not an integer
    if self.ext_death_year.present?
      if self.ext_death_year.to_i == 0
        errors.add(:death_year, "Please check the format of the death year.")
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
  def get_person_name
    [prefix, first_name, last_name, suffix, title].compact.join(" ")
  end
end

