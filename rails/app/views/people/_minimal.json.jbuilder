json.id person.id.to_s
json.attributes do
  json.name person.display_name
  json.degree person.relationships.count
  json.groups person.groups.map{|p| p.id.to_s}
end
json.type "person"