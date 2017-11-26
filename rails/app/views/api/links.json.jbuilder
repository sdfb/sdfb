if @errors
  json.errors { json.array! @errors }
else
  json.data do
    json.partial! 'user_rel_contribs/include', collection: @links, as: :link
  end
  json.included do
    json.partial! 'people/minimal', collection:  @people, as: :person
  end
  json.meta do
    json.partial! "investigators"
  end
end