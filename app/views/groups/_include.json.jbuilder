json.id group.id.to_s
json.attributes do
  json.name group.name
  json.description group.description
  json.start_year group.start_year
  json.end_year group.end_year
end
json.type "group"
