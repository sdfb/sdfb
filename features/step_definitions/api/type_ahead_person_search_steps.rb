Given(/^I have a search string matching the name of an existing person$/) do
  @search_string = Person.first.display_name[0,2]
end

Given(/^I have an unlikely to match search string$/) do
  @search_string = 'QZQ'
end

When(/^I access the type ahead endpoint with the search string$/) do
  get("/api/typeahead?type=person&q=#{@search_string}", format: :json)
end

Then(/^the data includes only people with names containing the search string$/) do
  @data.each do |d|
    expect d["attributes"]["name"].starts_with?(@search_string)
  end
end
