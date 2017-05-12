Given(/^I have a search string matching the name of an existing group$/) do
  @search_group = Group.first
  @search_string = @search_group.name[0,2]
end

Then(/^the data looks like a list of one group search result$/) do
  group_as_search_result = {
    "name" => @search_group.name,
    "id" => @search_group.id.to_s
  }
  expect(@data).to be_an Array
  expect(@data.size).to eq 1
  expect(@data.first).to eq(group_as_search_result)
end
