if @relationships
  json.data do
    json.partial! 'relationships/minimal', collection: @relationships, as: :relationship
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end