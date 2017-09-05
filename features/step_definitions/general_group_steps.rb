Given(/^(\d+) groups exist$/) do |n|
  @groups = []
  @group_start_year = SDFB::EARLIEST_YEAR + 1
  @group_end_year = SDFB::LATEST_YEAR - 1

  n.to_i.times do |i|
    @groups << Group.create(
      name:            "G#{i} Everyone is Cool Club",
      is_approved:     true,
      description:     "-",
      start_year:      @group_start_year,
      start_date_type: "IN",
      end_year:        @group_end_year,
      end_date_type:   "IN",
      created_by:      @sdfbadmin.id,
      approved_by:     @sdfbadmin.id.to_s
    )
  end
end

Given(/^a group exists$/) do
  @group_start_year = SDFB::EARLIEST_YEAR + 1
  @group_end_year = SDFB::LATEST_YEAR - 1

  @group = Group.create(
    name:            'First Everyone is Cool Club',
    is_approved:     true,
    description:     "-",
    start_year:      @group_start_year,
    start_date_type: "IN",
    end_year:        @group_end_year,
    end_date_type:   "IN",
    created_by:      @sdfbadmin.id,
    approved_by:     @sdfbadmin.id.to_s
  )
end

Given(/^a second group exists$/) do
  @group2_start_year = SDFB::EARLIEST_YEAR + 1
  @group2_end_year = SDFB::LATEST_YEAR - 1

  @group2 = Group.create(
    name:            'More than Everyone is Cool Club Two',
    is_approved:     true,
    description:     "-",
    start_year:      @group2_start_year,
    start_date_type: "IN",
    end_year:        @group2_end_year,
    end_date_type:   "IN",
    created_by:      @sdfbadmin.id,
    approved_by:     @sdfbadmin.id.to_s
  )
end

Given(/^multiple groups exist$/) do
  step 'a group exists'
  step 'a second group exists'
  @groups = [@group, @group2]
end

Given(/^a person is in the group$/) do
  @in_group_person = Person.where(
      first_name: 'In',
      last_name: 'Group',
      created_by: @sdfbadmin.id,
      gender: 'female',
      birth_year_type: 'IN',
      ext_birth_year: '1528',
      death_year_type: 'IN',
      ext_death_year: '1610',
      approved_by: @sdfbadmin.id,
      is_approved: true
  ).first_or_create!

  assign = GroupAssignment.new(created_by: @sdfbadmin.id)
  assign.group = @group
  assign.person = @in_group_person
  assign.save!
end
