When(/^I access the type ahead endpoint with the search string, looking for a "([^"]*)"$/) do |search_type|
  get("/api/typeahead?type=#{search_type}&q=#{@search_string}", format: :json)
end

Given(/^I have an unlikely to match search string$/) do
  @search_string = 'QZQ'
end

Then(/^the data looks like an empty list$/) do
  expect(@data).to be_an Array
  expect(@data).to be_empty
end

Then(/^the data includes only results with names containing the search string$/) do
  @data.each do |d|
    expect d["name"].starts_with?(@search_string)
  end
end
