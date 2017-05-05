if @errors
  json.errors { json.array! @errors }
else
  json.data do
    json.id @people.first.id
    json.type "network"
    json.attributes do
      json.connections do
        json.array! @relationships do |relationship|
          json.id relationship.id
          json.type "relationship"
          json.attributes do
            json.altered true
            json.end_year relationship.end_year
            json.source relationship.person2_index
            json.start_year relationship.start_year
            json.target relationship.person1_index
            json.weight relationship.max_certainty
          end
        end
      end
      json.nodes do

      end
    end
  end
  json.includes do
    json.partial! 'people/include', collection: @people, as: :person
  end
  json.meta do
    json.partial! "investigators"
  end
end
