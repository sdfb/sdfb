if @groups
  json.data do
    json.id @display_id
    json.type "network"
    json.attributes do
      json.primary_people @primary_people ? @primary_people.map{|p| p["id"].to_s} : []
      json.connections do
        json.partial! 'relationships/metadata', collection: @relationships, as: :relationship
      end
    end
  end
  if @people || @groups
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
