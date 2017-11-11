if @errors
  json.errors { json.array! @errors }
else
  json.data do
    json.id @display_id
    json.type "network"
    json.attributes do
      json.primary_people @people.map{|p| p["id"].to_s}
      json.connections do
        json.partial! 'relationships/metadata', collection: @relationships, as: :relationship
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