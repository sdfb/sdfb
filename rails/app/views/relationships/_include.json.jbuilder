json.id relationship.id.to_s
json.attributes do
  json.person_1 relationship.person1_index
  json.person_2 relationship.person2_index
  json.start_year relationship.start_year
  json.end_year relationship.end_year
  json.start_year_type relationship.start_date_type
  json.end_year_type relationship.end_date_type


end
json.type "relationship"
