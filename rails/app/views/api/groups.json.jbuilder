if @groups
  json.data do
    json.partial! 'groups/include', collection: @groups, as: :group
  end
  json.includes do
    json.partial! 'people/include', collection: @people, as: :person
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end
