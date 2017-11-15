json.id relationship.id.to_s
json.type "relationship"
json.attributes do
  json.altered relationship.altered
  json.end_year relationship.end_year
  json.end_year_type relationship.end_date_type
  json.source relationship.person2_index.to_s
  json.start_year relationship.start_year
  json.start_year_type relationship.start_date_type
  json.target relationship.person1_index.to_s
  json.weight relationship.max_certainty
  json.created_by relationship.created_by
end