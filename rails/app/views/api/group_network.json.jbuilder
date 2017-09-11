if @groups
  json.data do
    json.id @display_id
    json.type "network"
    json.attributes do
      json.primary_people @people.map{|p| p["id"].to_s}
      json.connections do
        json.array! @relationships do |relationship|
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
          end
        end
      end
      # json.nodes do

      # end
    end
  end
  if @people
    json.included do
      json.partial! 'people/include', collection: @people, as: :person
      json.partial! 'groups/include', collection: @groups, as: :group
    end
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end
