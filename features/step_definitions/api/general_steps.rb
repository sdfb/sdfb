When(/^I am given json$/) do
  @data = MultiJson.load(last_response.body)["data"]
  @included_data = MultiJson.load(last_response.body)["included"]
  @errors = MultiJson.load(last_response.body)["errors"]
end

Then(/^the json is valid JSON\-API$/) do
   raw_json = MultiJson.load(last_response.body).to_json
   expect(raw_json).to match_response_schema("jsonapi")
end

Then(/^the errors include "([^"]*)"$/) do |error_message|
  expect(@errors.size).to eq 1
  expect(@errors.first["title"]).to eq error_message
end
