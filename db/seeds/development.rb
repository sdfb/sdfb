creator_id = User.first.id

francis = Person.where(
  id: 10000473,
  first_name: 'Francis',
  last_name: 'Bacon',
  created_by: creator_id,
  gender: 'male',
  birth_year_type: 'IN',
  ext_birth_year: '1561',
  death_year_type: 'IN',
  ext_death_year: '1626',
  approved_by: creator_id,
  is_approved: true
).first_or_create!

anne = Person.where(
  first_name: 'Anne',
  last_name: 'Bacon',
  created_by: creator_id,
  gender: 'female',
  birth_year_type: 'IN',
  ext_birth_year: '1528',
  death_year_type: 'IN',
  ext_death_year: '1610',
  approved_by: creator_id,
  is_approved: true
).first_or_create!

anne_and_francis_relationship = Relationship.where(
  person1_index: anne.id,
  person2_index: francis.id,
  original_certainty: 100,
  created_by: User.first,
  approved_by: creator_id,
  is_approved: true
).first_or_create!
