Given(/^the "([^"]*)" relationship type exists with id (\d+)$/) do |name, id|
  r = RelationshipType.new(name: name)
  r.id = id
  r.save!
end

Given(/^a relationship exists$/) do
  francis = Person.where(
    first_name: 'Francis',
    last_name: 'Bacon',
    created_by: @sdfbadmin.id,
    gender: 'male',
    birth_year_type: 'IN',
    ext_birth_year: '1561',
    death_year_type: 'IN',
    ext_death_year: '1626',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!

  @anne = Person.where(
    first_name: 'Anne',
    last_name: 'Bacon',
    created_by: @sdfbadmin.id,
    gender: 'female',
    birth_year_type: 'IN',
    ext_birth_year: '1528',
    death_year_type: 'IN',
    ext_death_year: '1610',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!

  @relationship = Relationship.where(
    person1_index: francis.id,
    person2_index: @anne.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

Given(/^a second degree relationship exists$/) do
  third_wheel = Person.where(
    first_name: 'Friend of',
    last_name: 'An Baco',
    created_by: @sdfbadmin.id,
    gender: 'female',
    birth_year_type: 'IN',
    ext_birth_year: '1528',
    death_year_type: 'IN',
    ext_death_year: '1610',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!

  @relationship_once_removed = Relationship.where(
    person1_index: @anne.id,
    person2_index: third_wheel.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

When(/^I change the relationship dates$/) do
  @relationship.update_attributes(
    start_year: 1580,
    start_month: 'Mar',
    start_day: 15,
    end_year: 1580,
    end_month: 'Mar',
    end_day: 15,
  )
end

When(/^I create a new relationship between (\d+) and (\d+)$/) do |start_year, end_year|
    @new_relationship = Relationship.new(
    person1_index: @anne.id,
    person2_index: @francis.id,
    original_certainty: 100,
    start_year: start_year,
    start_month: "Jan",
    start_day: 1,
    start_date_type: "CA",
    end_year: end_year,
    end_month: "Dec",
    end_day: 31,
    end_date_type: "CA",
    created_by: @sdfbadmin.id
  )
end


Then(/^the new relationship has an invalid "([^"]*)"$/) do |error_field|
  expect(@new_relationship.valid?).to be false
  expect(@new_relationship.errors.count).to eq(1)
  expect(@new_relationship.errors.first).to include(error_field.to_sym)
end



Then(/^a relationship type is created for the relationship$/) do
  expect(UserRelContrib.last.relationship_id).to eq @relationship.id
end

Then(/^the relationship type has the same start date as the relationship$/) do
  expect(UserRelContrib.last.start_year).to eq @relationship.start_year
  expect(UserRelContrib.last.start_day).to eq @relationship.start_day
  expect(UserRelContrib.last.start_month).to eq @relationship.start_month
end

Then(/^the relationship type has the same end date as the relationship$/) do
  expect(UserRelContrib.last.end_year).to eq @relationship.end_year
  expect(UserRelContrib.last.end_day).to eq @relationship.end_day
  expect(UserRelContrib.last.end_month).to eq @relationship.end_month
end
