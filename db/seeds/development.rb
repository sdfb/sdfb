require "csv"

# Configure a couple defaults
tsv_options = { :col_sep => "\t" }
sdfb_admin_id = User.first.id

# Add all of the Group Category data from the dump
CSV.foreach(Rails.root.join('lib', 'data', 'group_categories.tsv'), tsv_options) do |line|
  GroupCategory.where(
    id: line[0],
    name: line[1],
    is_approved: true,
    created_by: sdfb_admin_id,
    approved_by: sdfb_admin_id.to_s
  ).first_or_create!
end

# Add all of the Group data from the dump
CSV.foreach(Rails.root.join('lib', 'data', 'groups.tsv'), tsv_options) do |line|
  Group.where(
    id:              line[0],
    name:            line[1],
    is_approved:     true,
    description:     line[2] || "-",
    start_year:      line[3] || 1500,
    start_date_type: line[3].present? ? "IN" : "CA",
    end_year:        line[4] || 1700,
    end_date_type:   line[4].present? ? "IN" : "CA",
    created_by: sdfb_admin_id,
    approved_by: sdfb_admin_id.to_s
  ).first_or_create!
end

# Preload some important people.
francis = Person.where(
  id: 10000473,
  first_name: 'Francis',
  last_name: 'Bacon',
  created_by: sdfb_admin_id,
  gender: 'male',
  birth_year_type: 'IN',
  ext_birth_year: '1561',
  death_year_type: 'IN',
  ext_death_year: '1626',
  approved_by: sdfb_admin_id,
  is_approved: true
).first_or_create!

anne = Person.where(
  first_name: 'Anne',
  last_name: 'Bacon',
  created_by: sdfb_admin_id,
  gender: 'female',
  birth_year_type: 'IN',
  ext_birth_year: '1528',
  death_year_type: 'IN',
  ext_death_year: '1610',
  approved_by: sdfb_admin_id,
  is_approved: true
).first_or_create!

anne_and_francis_relationship = Relationship.where(
  person1_index: anne.id,
  person2_index: francis.id,
  original_certainty: 100,
  created_by: User.first,
  approved_by: sdfb_admin_id,
  is_approved: true
).first_or_create!
