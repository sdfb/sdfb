Given(/^I have a search string matching the name of an existing group$/) do
  @search_group = Group.first
  @search_string = @search_group.name[0,2]
end
