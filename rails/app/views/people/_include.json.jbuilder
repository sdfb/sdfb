json.id person.id.to_s
json.attributes do
  json.birth_year person.ext_birth_year
  json.birth_year_type person.birth_year_type
  json.death_year person.ext_death_year
  json.death_year_type person.death_year_type
  json.odnb_id person.odnb_id
  json.gender person.gender
  json.historical_significance person.historical_significance
  json.name person.display_name
  json.groups person.approved_group_ids

end
json.type "person"