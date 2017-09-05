Given(/^each person has a unique relationship$/) do
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

  anne = Person.where(
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
    person1_index: @people.first.id,
    person2_index: francis.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!

  @relationship2 = Relationship.where(
    person1_index: @people.second.id,
    person2_index: anne.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

Given(/^each person has met a specified given person$/) do
  @common_friend = Person.where(
    first_name: 'Common',
    last_name: 'Friend',
    created_by: @sdfbadmin.id,
    gender: 'female',
    birth_year_type: 'IN',
    ext_birth_year: '1528',
    death_year_type: 'IN',
    ext_death_year: '1610',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
  
  @shared_relationship = Relationship.where(
    person1_index: @people.first.id,
    person2_index: @common_friend.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!

  @shared_relationship2 = Relationship.where(
    person1_index: @people.second.id,
    person2_index: @common_friend.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

When(/^I access the shared network api endpoint for those people$/) do
  get("/api/network?ids=#{@people.collect(&:id).join(',')}", format: :json)
end

Then(/^the data contains the relationships of each person$/) do
  received_relationship_ids = @data["attributes"]["connections"].map{|i| i["id"].to_i}
  expected_relationship_ids = [@relationship.id, @relationship2.id, @shared_relationship.id, @shared_relationship2.id]

  expect(received_relationship_ids.sort).to eq(expected_relationship_ids.sort)
end
