Given(/^a relationship exists for a group member$/) do
  @not_in_group_person = Person.where(
    first_name: 'Not In',
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

  @relationship = Relationship.where(
    person1_index: @in_group_person.id,
    person2_index: @not_in_group_person.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

When(/^I access the api endpoint for the group network$/) do
  get("/api/groups/network?ids=#{@group.id}", format: :json)
end

When(/^I access the api endpoint for the group$/) do
  get("/api/groups?ids=#{@group.id}", format: :json)
end

When(/^I access the api endpoint for all groups$/) do
  get("/api/groups", format: :json)
end

When(/^I access the api endpoint for those groups$/) do
  get("/api/groups?ids=#{@groups.collect(&:id).join(',')}", format: :json)
end

When(/^I access the api endpoint for a group with an invalid ID$/) do
  get("/api/groups?ids=banana", format: :json)
end

Then(/^the data looks like a list of one group$/) do
  expect(@data).to be_an Array

  group_data = @data.first
  preferred_keys = [
    "id","attributes","type"
  ]
  expect(group_data.keys).to eq(preferred_keys)

  attribute_keys = ["name", "description", "start_year", "end_year", "people"]
  expect(group_data["attributes"].keys).to eq(attribute_keys)
end

Then(/^the data has correct information for the group$/) do
  group_data = @data.first
  expect(group_data["attributes"]["name"]).to eq(@group.name)
  expect(group_data["attributes"]["description"]).to eq(@group.description)
  expect(group_data["attributes"]["start_year"]).to eq(@group.start_year)
  expect(group_data["attributes"]["end_year"]).to eq(@group.end_year)
  expect(group_data["id"]).to eq(@group.id.to_s)
  expect(group_data["type"]).to eq("group")
end

Then(/^the data looks a list containing (\d+) groups$/) do |n|
  expect(@data).to be_an Array
  expect(@data.size).to eq(n.to_i)
end

Then(/^the data has correct ids for those groups$/) do
  given_ids = @data.collect{|i| i["id"]}
  expected_ids = @groups.map{|p| p["id"].to_s}

  expect(given_ids.count).to eq(@groups.size)
  expect(given_ids.sort).to eq(expected_ids.sort)
end

Then(/^the included data has information for the relationship members$/) do
  not_in_group_person_data = {
    "id" => @not_in_group_person.id.to_s,
    "attributes" => {
      "birth_year"=> @not_in_group_person.ext_birth_year,
      "death_year"=> @not_in_group_person.ext_death_year,
      "historical_significance"=> @not_in_group_person.historical_significance,
      "name" => @not_in_group_person.display_name,
      "degree" => @not_in_group_person.relationships.count,
      "groups" => @not_in_group_person.groups.to_a
    },
    "type" => "person"
  }
  expect(@included_data).to include(not_in_group_person_data)
end
