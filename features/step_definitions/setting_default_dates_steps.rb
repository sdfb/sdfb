Given(/^a person exists$/) do
  @person = Person.create(
    first_name: 'Grouper',
    last_name: 'McMember',
    created_by: @sdfbadmin.id,
    gender: 'male',
    birth_year_type: 'IN',
    ext_birth_year: '1580',
    death_year_type: 'IN',
    ext_death_year: '1610',
    approved_by: @sdfbadmin.id,
    is_approved: true
  )
end

Given(/^a group exists$/) do
  @group = Group.create(
    name:            'Everyone is Cool Club',
    is_approved:     true,
    description:     "-",
    start_year:      SDFB::EARLIEST_YEAR,
    start_date_type: "IN",
    end_year:        SDFB::LATEST_YEAR,
    end_date_type:   "IN",
    created_by:      @sdfbadmin.id,
    approved_by:     @sdfbadmin.id.to_s
  )
end

Given(/^the group started before the person was born$/) do
  group_start_year = @person.ext_birth_year.to_i - 1
  @group.update_attributes(start_year: group_start_year)
end

Given(/^the group ended after the person died$/) do
  group_end_year = @person.ext_death_year.to_i + 1
  @group.update_attributes(end_year: group_end_year)
end

Given(/^I do not know when the person joined or departed the group$/) do
  @group_join_date = nil
  @group_leave_date = nil
end

When(/^I assign the person to the group$/) do
  GroupAssignment.create(
    person_id: @person.id,
    group_id: @group.id,
    created_by: @sdfbadmin.id,
    start_year: @group_join_date,
    end_year: @group_leave_date
  )
end

Then(/^a group membership is created for the person and the group$/) do
  expect(GroupAssignment.last.person_id).to eq @person.id
  expect(GroupAssignment.last.group_id).to eq @group.id
end

Then(/^the group membership's start date is the person's birth date$/) do
  expect(GroupAssignment.last.start_year).to eq @person.ext_birth_year
end

Then(/^the group membership's end date is the person's death date$/) do
  expect(GroupAssignment.last.end_year).to eq @person.ext_death_year
end
