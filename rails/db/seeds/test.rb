require "csv"

# Configure a couple defaults
tsv_options = { :col_sep => "\t" }
sdfb_admin_id = User.first.id


# Add all of the Group data from the dump
CSV.foreach(Rails.root.join('lib', 'data', 'groups.tsv'), tsv_options) do |line|
  Group.where(
    id:              line[0],
    name:            line[1],
    is_approved:     true,
    description:     line[2] || "-",
    start_year:      line[3] || SDFB::EARLIEST_YEAR,
    start_date_type: line[3].present? ? "IN" : "CA",
    end_year:        line[4] || SDFB::LATEST_YEAR,
    end_date_type:   line[4].present? ? "IN" : "CA",
    created_by:      sdfb_admin_id,
    approved_by:     sdfb_admin_id.to_s
  ).first_or_create!
end
ActiveRecord::Base.connection.reset_pk_sequence!("groups")

# Add all of the Relationship Category data from the dump
CSV.foreach(Rails.root.join('lib', 'data', 'rel_categories.tsv'), tsv_options) do |line|
  RelationshipCategory.where(
    id:              line[0],
    name:            line[1],
    is_approved:     true,
    created_by:      sdfb_admin_id,
    approved_by:     sdfb_admin_id.to_s,
  ).first_or_create!
end
ActiveRecord::Base.connection.reset_pk_sequence!("relationship_categories")


# Add all of the Relationship Type data from the dump
CSV.foreach(Rails.root.join('lib', 'data', 'rel_types.tsv'), tsv_options) do |line|
  RelationshipType.where(
    id:              line[0],
    name:            line[1],
    relationship_type_inverse: line[2],
    is_approved:     true,
    created_by:      sdfb_admin_id,
    approved_by:     sdfb_admin_id.to_s,
  ).first_or_create!
end
ActiveRecord::Base.connection.reset_pk_sequence!("relationship_types")


# Add all of the Relationship Category Assignment data from the dump
CSV.foreach(Rails.root.join('lib', 'data', 'rel_cat_assignments.tsv'), tsv_options) do |line|
  RelCatAssign.where(
    relationship_type_id:      line[0],
    relationship_category_id:  line[1],
    is_approved:     true,
    created_by:      sdfb_admin_id,
    approved_by:     sdfb_admin_id.to_s,
  ).first_or_create!
end
ActiveRecord::Base.connection.reset_pk_sequence!("rel_cat_assigns")


# Preload some important people.
francis = Person.where(
  id: SDFB::FRANCIS_BACON,
  first_name: 'Francis',
  last_name: 'Bacon',
  created_by: sdfb_admin_id,
  gender: 'male',
  birth_year_type: 'IN',
  birth_year: '1561',
  death_year_type: 'IN',
  death_year: '1626',
  approved_by: sdfb_admin_id,
  is_approved: true
).first_or_create!

anne = Person.where(
  first_name: 'Anne',
  last_name: 'Bacon',
  created_by: sdfb_admin_id,
  gender: 'female',
  birth_year_type: 'IN',
  birth_year: '1528',
  death_year_type: 'IN',
  death_year: '1610',
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

third_wheel = Person.where(
  first_name: 'Friend of',
  last_name: 'An Baco',
  created_by: sdfb_admin_id,
  gender: 'female',
  birth_year_type: 'IN',
  birth_year: '1528',
  death_year_type: 'IN',
  death_year: '1610',
  approved_by: sdfb_admin_id,
  is_approved: true
).first_or_create!

@relationship_once_removed = Relationship.where(
  person1_index: anne.id,
  person2_index: third_wheel.id,
  original_certainty: 100,
  created_by: User.first,
  approved_by: sdfb_admin_id,
  is_approved: true
).first_or_create!
