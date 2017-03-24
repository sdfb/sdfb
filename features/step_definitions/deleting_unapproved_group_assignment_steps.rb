require "cancan/matchers"

Given(/^there is unapproved "([^"]*)" relationship$/) do |rel_type_name|
  UserRelContrib.where(
    relationship_id:       @relationship.id,
    relationship_type_id:  RelationshipType.where(name: rel_type_name).first.id,
    annotation:            "Somebody was very, very hungry.",
    certainty:             100,
    is_approved:           false,
    created_by:            @sdfbadmin.id
  ).first_or_create!
end

Then(/^the "([^"]*)" relationship should exist$/) do |rel_type_name|
  relationship_type = RelationshipType.where(name: rel_type_name).first
  relationships = @relationship.user_rel_contribs.map{|c| c.relationship_type.id}
  expect(relationships).to include(relationship_type.id)
end

Then(/^the curator can delete the "([^"]*)" relationship$/) do |rel_type_name|
  ability = Ability.new(@curator)
  relationship_type = RelationshipType.where(name: rel_type_name).first
  user_rel_type = @relationship.user_rel_contribs.where(relationship_type_id: relationship_type.id).first
  ability.should be_able_to(:destroy,user_rel_type)
end