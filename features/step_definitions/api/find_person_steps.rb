When(/^I access the api endpoint for the person$/) do
  get("/api/people?ids=#{@person.id}", format: :json)
end

When(/^I access the api endpoint for those people$/) do
  get("/api/people?ids=#{@people.collect(&:id).join(',')}", format: :json)
end

When(/^I access the relationship api endpoint for one of the people in that relationship$/) do
  get("/api/person_network/#{@relationship.person1_index}", format: :json)
end

When(/^I access the api endpoint for a person with an invalid ID$/) do
  get("/api/people?ids=banana", format: :json)
end

Then(/^I am given json that looks a person$/) do
  @json = MultiJson.load(last_response.body)["data"].first
  preferred_keys = [
    "id","attributes","type"
  ]
  expect(@json.keys).to eq(preferred_keys)

  attribute_keys = [
    "birth_year","death_year","historical_significance","name"
  ]
  expect(@json["attributes"].keys).to eq(attribute_keys)

end

Then(/^the json has correct information for the person$/) do
  expect(@json["attributes"]["birth_year"]).to eq(@person.ext_birth_year)
  expect(@json["attributes"]["death_year"]).to eq(@person.ext_death_year)
  expect(@json["attributes"]["historical_significance"]).to eq(@person.historical_significance)
  expect(@json["id"]).to eq(@person.id)
  expect(@json["attributes"]["name"]).to eq(@person.display_name)
  expect(@json["type"]).to eq("people")
end

Then(/^I am given json that looks a list containing (\d+) people$/) do |n|
  @json = MultiJson.load(last_response.body)
  expect(@json["data"]).to be_an Array
  expect(@json["data"].count).to eq(n.to_i)
end

Then(/^the json has correct ids for those people$/) do
  given_ids = @json["data"].collect{|i| i["id"]}
  expected_ids = @people.collect(&:id)

  expect(given_ids.count).to eq(@people.size)
  expect(given_ids.sort).to eq(expected_ids.sort)
end

Then(/^I am given json that includes a list of relationships$/) do
  @json = MultiJson.load(last_response.body)["data"]
  expect(@json["attributes"]).keys to_include("links")
end

Then(/^the json contains the relationship$/) do
  expected_data = {
    "altered": true,
    "end_year": @relationship.end_year,
    "id": @relationship.id,
    "target": @relationship.person1_index,
    "start_year": @relationship.start_year,
    "source": @relationship.person2_index,
    "weight": @relationship.weight
  }
  expect(@json["attributes"]["links"].first).to eq(expected_data)
end

Then(/^I am given a json error telling me "([^"]*)"$/) do |error_message|
  @json = MultiJson.load(last_response.body)["errors"]
  expect(@json.size).to eq 1
  expect(@json.first["title"]).to eq error_message
end
