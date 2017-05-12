When(/^I access the api endpoint for the group$/) do
  get("/api/groups?ids=#{@group.id}", format: :json)
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

  attribute_keys = ["name", "description", "start_year", "end_year"]
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
