json.id relationship.id.to_s
json.created_by relationship.created_by
json.types do
  json.array! relationship.user_rel_contribs do |rel_type|
    json.type rel_type.relationship_type_id
    json.confidence rel_type.certainty
    json.start_year rel_type.start_year
    json.start_year_type rel_type.start_date_type
    json.end_year rel_type.end_year
    json.end_year_type rel_type.end_date_type
    json.created_by rel_type.created_by
    json.citations rel_type.citation
  end
end
json.type "relationship"
