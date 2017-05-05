Then(/^I am given a json error telling me "([^"]*)"$/) do |error_message|
  @json = MultiJson.load(last_response.body)["errors"]
  expect(@json.size).to eq 1
  expect(@json.first["title"]).to eq error_message
end
