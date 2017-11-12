json.id person.id.to_s
json.attributes do
  json.name person.display_name
  json.groups person.approved_group_ids
end
json.type "person"