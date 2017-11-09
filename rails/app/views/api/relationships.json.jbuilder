if @relationships
  json.data do
    json.partial! 'relationships/minimal', collection: @relationships, as: :relationship
  end
  json.included do
    # json.partial! 'people/minimal', collection:  @people, as: :person
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end