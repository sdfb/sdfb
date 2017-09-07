Given(/^a person has been added to a group$/) do
  @group_assignment = GroupAssignment.create(
    person_id: @person.id,
    group_id: @group.id,
    created_by: @sdfbadmin.id
  )
end

Then(/^the curator is able to delete the group assignment$/) do
  ability = Ability.new(@curator)
  expect(ability).to be_able_to(:destroy, @group_assignment)
end

Then(/^the curator is able to reject the group assignment$/) do
  ability = Ability.new(@curator)
  expect(ability).to be_able_to(:update, @group_assignment)
end

Then(/^it is possible to reject the group assignment$/) do
  @group_assignment.is_rejected = true
  @group_assignment.save
  expect(@group_assignment.is_rejected).to be true
end

Then(/^the standard user is not able to delete the group assignment$/) do
  ability = Ability.new(@standard_user)
  expect(ability).not_to be_able_to(:destroy, @group_assignment)
end

Then(/^the standard user is not able to reject the group assignment$/) do
  ability = Ability.new(@standard_user)
  expect(ability).not_to be_able_to(:update, @group_assignment)
end