Given(/^a group exists$/) do
  @group_start_year = SDFB::EARLIEST_YEAR + 1
  @group_end_year = SDFB::LATEST_YEAR - 1

  @group = Group.create(
    name:            'Everyone is Cool Club',
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
    name:            'Everyone is Cool Club Two',
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
