json.id person.id.to_s
json.attributes do
  json.birth_year person.ext_birth_year
  json.death_year person.ext_death_year
  json.historical_significance person.historical_significance
  json.name person.display_name
end
json.type "people"