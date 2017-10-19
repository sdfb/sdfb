json.id person.id.to_s
json.attributes do
  json.name person.display_name
  json.degree person.relationships.to_a.count
  json.groups person.approved_groups.map{|group| group.id.to_s}
end
json.type "person"