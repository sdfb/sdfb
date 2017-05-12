json.id person.id.to_s
json.attributes do
  json.name person.display_name
  json.degree person.relationships.count

end
json.type "person"