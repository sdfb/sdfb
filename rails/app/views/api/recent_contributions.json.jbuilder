if @people
  json.data do
    json.people do
      json.partial! 'people/include', collection: @people, as: :person
    end
    json.groups do
      json.partial! 'groups/include', collection: @groups, as: :group
    end
    json.group_assignments do
      json.partial! "group_assignments/include", collection: @assignments, as: :assignment 
    end
    json.relationships do
      json.partial! 'relationships/include', collection: @relationships, as: :relationship
    end
    json.links do
      json.partial! 'user_rel_contribs/include', collection: @links, as: :link
    end
  end

  json.includes do
    json.partial! 'people/minimal', collection: @other_people, as: :person
    json.partial! 'groups/minimal', collection: @other_groups, as: :group
  end

else
  json.errors { json.array! @errors }
end
json.meta do
  json.partial! "investigators"
end