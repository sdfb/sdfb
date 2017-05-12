Given(/^I have a search string matching the name of an existing person$/) do
  @search_person = Person.first
  @search_string = @search_person.display_name[0,2]
end

Given(/^I have an unlikely to match search string$/) do
  @search_string = 'QZQ'
end

When(/^I access the type ahead endpoint with the search string$/) do
  get("/api/typeahead?type=person&q=#{@search_string}", format: :json)
end

Then(/^the data includes only people with names containing the search string$/) do
  @data.each do |d|
    expect d["name"].starts_with?(@search_string)
  end
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

Then(/^the data looks like an empty list$/) do
  expect(@data).to be_an Array
  expect(@data).to be_empty
end
