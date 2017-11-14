if @errors
  json.errors { json.array! @errors }
else
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
            json.created_by relationship.created_by
          end
        end
        # This is an unrolling of:
        #json.partial! 'relationships/metadata', collection: @relationships, as: :relationship
      end
    end
  end
  json.included do
    json.partial! 'people/include', collection: @people, as: :person
    json.partial! 'people/minimal', collection:  @sources, as: :person
  end
  json.meta do
    json.partial! "investigators"
  end
end