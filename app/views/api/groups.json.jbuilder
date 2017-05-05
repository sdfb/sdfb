if @groups
  json.data do
    json.partial! 'groups/include', collection: @groups, as: :group
  end
else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end
