if @errors
  json.errors { json.array! @errors }
else
  json.data do
    json.array! @links do |link|
      json.id link.id.to_s
      json.type "link"
      json.attributes do
        json.type link.relationship_type.name
        json.confidence link.certainty
        json.start_year link.start_year
        json.start_year_type link.start_date_type
        json.end_year link.end_year
        json.end_year_type link.end_date_type
        json.citations link.citation
        json.created_by link.created_by
        json.relationship  link.relationship, partial: 'relationships/include', as: :relationship 
      end
    end
  end
  json.included do
    json.partial! 'people/minimal', collection:  @people, as: :person
  end
  json.meta do
    json.partial! "investigators"
  end
end