
json.id assignment.id.to_s
json.attributes do
  json.person_id assignment.person_id
  json.group_id assignment.group_id
  json.end_year assignment.end_year
  json.end_year_type assignment.end_date_type
  json.start_year assignment.start_year
  json.start_year_type assignment.start_date_type
end
json.type "group_assignment"