if @people
  json.data do
    json.partial! 'people/include', collection: @people, as: :person
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end