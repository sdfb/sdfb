Given(/^I have a search string matching the name of an existing person$/) do
  @search_person = Person.first
  @search_string = @search_person.display_name[0,2]
end

Then(/^the data looks like a list of one search result$/) do
  person_as_search_result = {
    "name" => @search_person.display_name,
    "id" => @search_person.id.to_s
  }
  expect(@data).to be_an Array
  expect(@data.size).to eq 1
  expect(@data.first).to eq(person_as_search_result)
end
