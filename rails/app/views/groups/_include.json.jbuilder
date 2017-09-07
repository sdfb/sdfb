json.id group.id.to_s
json.attributes do
  json.name group.name
  json.description group.description
  json.start_year group.start_year
  json.end_year group.end_year
  json.people do
    json.array! group.group_assignments do |assignment|
     json.person_id assignment.person_id
     json.end_year assignment.end_year
     json.end_year_type assignment.end_date_type
     json.start_year assignment.start_year
     json.start_year_type assignment.start_date_type
   end
  end
end
json.type "group"