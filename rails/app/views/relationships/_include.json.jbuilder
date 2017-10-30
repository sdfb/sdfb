json.id relationship.id.to_s
json.attributes do
  json.person_1 relationship.person1_index
  json.person_2 relationship.person2_index
end
json.type "relationship"
