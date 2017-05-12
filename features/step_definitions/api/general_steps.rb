When(/^I am given json$/) do
  @full_json = MultiJson.load(last_response.body)
  if @full_json.is_a? Hash
    @data = @full_json["data"]
    @included_data = @full_json["included"]
    @errors = @full_json["errors"]
  else
    @data = @full_json
  end
end

Then(/^the json is valid JSON\-API$/) do
   raw_json = MultiJson.load(last_response.body).to_json
   expect(raw_json).to match_response_schema("jsonapi")
end

Then(/^the errors include "([^"]*)"$/) do |error_message|
  expect(@errors.size).to eq 1
  expect(@errors.first["title"]).to eq error_message
end
