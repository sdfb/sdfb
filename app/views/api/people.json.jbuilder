json.data do
  if @people
    json.partial! 'people/include', collection: @people, as: :person
  end
end
json.errors do
  json.array! @errors
end
json.meta do
  json.partial! "investigators"
end