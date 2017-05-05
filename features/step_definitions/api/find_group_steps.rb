When(/^I access the api endpoint for the group$/) do
  get("/api/groups?ids=#{@group.id}", format: :json)
end

When(/^I access the api endpoint for those groups$/) do
  get("/api/groups?ids=#{@groups.collect(&:id).join(',')}", format: :json)
end

When(/^I access the api endpoint for a group with an invalid ID$/) do
  get("/api/groups?ids=banana", format: :json)
end

Then(/^I am given json that looks a group$/) do
  @json = MultiJson.load(last_response.body)["data"].first
  preferred_keys = [
    "id","attributes","type"
  ]
  expect(@json.keys).to eq(preferred_keys)

  attribute_keys = ["name", "description", "start_year", "end_year"]
  expect(@json["attributes"].keys).to eq(attribute_keys)

end

Then(/^the json has correct information for the group$/) do
  expect(@json["attributes"]["name"]).to eq(@group.name)
  expect(@json["attributes"]["description"]).to eq(@group.description)
  expect(@json["attributes"]["start_year"]).to eq(@group.start_year)
  expect(@json["attributes"]["end_year"]).to eq(@group.end_year)
  expect(@json["id"]).to eq(@group.id.to_s)
  expect(@json["type"]).to eq("group")
end

Then(/^I am given json that looks a list containing (\d+) groups$/) do |n|
  @json = MultiJson.load(last_response.body)
  expect(@json["data"]).to be_an Array
  expect(@json["data"].count).to eq(n.to_i)
end

Then(/^the json has correct ids for those groups$/) do
  given_ids = @json["data"].collect{|i| i["id"]}
  expected_ids = @groups.map{|p| p["id"].to_s}

  expect(given_ids.count).to eq(@groups.size)
  expect(given_ids.sort).to eq(expected_ids.sort)
end
