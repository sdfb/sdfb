json.id group.id.to_s
json.attributes do
  json.name group.name
  json.description group.description
  json.start_year group.start_year
  json.start_year_type group.end_date_type
  json.end_year group.end_year
  json.end_year_type group.end_date_type
  json.citations group.bibliography
  json.created_by group.created_by
  json.degree group.group_assignments.to_a.count

  json.people do
    json.array! group.group_assignments.all_approved do |assignment|
     json.person_id assignment.person_id
     json.end_year assignment.end_year
     json.end_year_type assignment.end_date_type
     json.start_year assignment.start_year
     json.start_year_type assignment.start_date_type
     json.created_by assignment.created_by
   end
  end
end
json.type "group"
