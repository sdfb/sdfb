json.data do
  json.attributes do
    json.connections do
      json.array! @connections do |connection|
        json.attributes do
          json.source connection[:source]
          json.target connection[:target]
          json.weight connection[:weight]
        end
        json.type "relationship"
        json.id "#{connection[:source]}&#{connection[:target]}"
      end
    end
  end
  json.id "all_groups"
  json.type "network"
end
json.included do
  json.array! @groups do |group|
    json.attributes do
      json.name group.name
      json.description group.description
      json.start_year group.start_year
      json.start_year_type group.start_date_type
      json.end_year group.end_year
      json.end_year_type group.end_date_type
      json.degree group.group_assignments.to_a.count
    end
    json.id group.id
    json.type "group"
  end
end
json.meta do
  json.partial! "investigators"
end
