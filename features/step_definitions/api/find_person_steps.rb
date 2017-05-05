When(/^I access the api endpoint for the person$/) do
  get("/people/#{@person.id}", format: :json)
end

Then(/^I am given json that looks a person$/) do
  @json = MultiJson.load(last_response.body)
  preferred_keys = [
    "birth_year","death_year","historical_significance","id","name",
    "type"
  ]
  expect(@json.keys).to eq(preferred_keys)
end

Then(/^the json has correct information for the person$/) do
  expect(@json["birth_year"]).to eq(@person.ext_birth_year)
  expect(@json["death_year"]).to eq(@person.ext_death_year)
  expect(@json["historical_significance"]).to eq(@person.historical_significance)
  expect(@json["id"]).to eq(@person.id)
  expect(@json["name"]).to eq(@person.name)
  expect(@json["type"]).to eq(@person.type)
end
