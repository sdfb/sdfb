Person.create!(
  first_name: 'Francis',
  last_name: 'Bacon',
  created_by: User.first.id,
  gender: 'male',
  birth_year_type: 'IN',
  ext_birth_year: 1561,
  death_year_type: 'IN',
  ext_death_year: 1626
)
