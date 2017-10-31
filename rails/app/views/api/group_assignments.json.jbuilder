if @assignments
  json.data do
    json.partial! "group_assignments/include", collection: @assignments, as: :assignment 
  end
  json.includes do
    json.partial! 'people/minimal', collection: @people, as: :person
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end
