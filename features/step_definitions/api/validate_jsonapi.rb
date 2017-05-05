Then(/^the json is valid JSON\-API$/) do
   raw_json = MultiJson.load(last_response.body).to_json
   expect(raw_json).to match_response_schema("jsonapi")
end
