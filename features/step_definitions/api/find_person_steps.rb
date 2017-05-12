When(/^I access the api endpoint for the person$/) do
  get("/api/people?ids=#{@person.id}", format: :json)
end

When(/^I access the api endpoint for those people$/) do
  get("/api/people?ids=#{@people.collect(&:id).join(',')}", format: :json)
end

When(/^I access the relationship api endpoint for one of the people in that relationship$/) do
  get("/api/network?ids=#{@relationship.person1_index}", format: :json)
end

When(/^I access the api endpoint for a person with an invalid ID$/) do
  get("/api/people?ids=banana", format: :json)
end

Then(/^the data looks like a list of one person$/) do
  expect(@data).to be_an Array

  person_data = @data.first
  preferred_keys = [
    "id","attributes","type"
  ]
  expect(person_data.keys).to eq(preferred_keys)

  attribute_keys = [
    "birth_year","death_year","historical_significance","name", "degree", "groups"
  ]
  expect(person_data["attributes"].keys).to eq(attribute_keys)

end

Then(/^the data has correct information for the person$/) do
  person_data = @data.first
  expect(person_data["attributes"]["birth_year"]).to eq(@person.ext_birth_year)
  expect(person_data["attributes"]["death_year"]).to eq(@person.ext_death_year)
  expect(person_data["attributes"]["historical_significance"]).to eq(@person.historical_significance)
  expect(person_data["id"]).to eq(@person.id.to_s)
  expect(person_data["attributes"]["name"]).to eq(@person.display_name)
  expect(person_data["type"]).to eq("person")
end

Then(/^the data looks a list containing (\d+) people$/) do |n|
  expect(@data).to be_an Array
  expect(@data.count).to eq(n.to_i)
end

Then(/^the data has correct ids for those people$/) do
  given_ids = @data.collect{|i| i["id"]}
  expected_ids = @people.map{|p| p["id"].to_s}

  expect(given_ids.count).to eq(@people.size)
  expect(given_ids.sort).to eq(expected_ids.sort)
end

Then(/^the data includes a list of relationships$/) do
  expect(@data["attributes"].keys).to include("connections")
end

Then(/^the data contains the relationship$/) do
  expected_data = {
    "altered" => true,
    "end_year" => @relationship.end_year,
    "target" => @relationship.person1_index.to_s,
    "start_year" => @relationship.start_year,
    "source" => @relationship.person2_index.to_s,
    "weight" => @relationship.max_certainty
  }
  expect(@data["attributes"]["connections"].first["id"]).to eq(@relationship.id.to_s)
  expect(@data["attributes"]["connections"].first["attributes"]).to eq(expected_data)
end

Then(/^the data contains references to the people in the relationship$/) do
  @person1 = Person.find(@relationship.person1_index)
  @person2 = Person.find(@relationship.person2_index)

  data_from_first_person = {
    "id" => @person1.id.to_s,
    "attributes" => {
      "birth_year" => @person1.ext_birth_year,
      "death_year" => @person1.ext_death_year,
      "historical_significance" => @person1.historical_significance,
      "name" => @person1.display_name,
      "degree" => 1,
      "groups" => @person1.groups.collect(&:id)
    },
    "type" => "person"
  }

  data_from_second_person = {
    "id" => @person2.id.to_s,
    "attributes" => {
      "birth_year" => @person2.ext_birth_year,
      "death_year" => @person2.ext_death_year,
      "historical_significance" => @person2.historical_significance,
      "name" => @person2.display_name,
      "degree" => 1,
      "groups" => @person2.groups.collect(&:id)
    },
    "type" => "person"
  }
  expect(@included_data).to include(data_from_first_person)
  expect(@included_data).to include(data_from_second_person)
end
