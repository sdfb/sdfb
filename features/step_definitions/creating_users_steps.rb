require "csv"

Given(/^required app users exist$/) do
  required_user_atts = {
    password: '22scaddoo',
    password_confirmation: '22scaddoo',
    first_name: 'Franny',
    last_name: 'Baker',
    user_type: 'Standard',
    is_active: true
  }
  @sdfbadmin = User.where(email: 'sdfbadmin@example.com', username: 'sdfbadmin').first_or_create!(required_user_atts)
  User.where(email: 'odnbadmin@example.com', username: 'odnbadmin').first_or_create!(required_user_atts)
  required_user_atts.merge!({user_type: 'Curator'})
  User.where(email: 'curator@example.com', username: 'curator').first_or_create!(required_user_atts)
  required_user_atts.merge!({user_type: 'Admin'})
  User.where(email: 'administrator@example.com', username: 'administrator').first_or_create!(required_user_atts)
end

Given(/^a curator user exists$/) do
  required_user_atts = {
    password: '22scaddoo',
    password_confirmation: '22scaddoo',
    first_name: 'Carrie',
    last_name: 'Curator',
    user_type: 'Curator',
    is_active: true
  }
  @curator = User.where(email: 'curator@example.com', username: 'curator').first_or_create!(required_user_atts)
end

Given(/^pre-defined data exists$/) do
  # Configure a couple defaults
  tsv_options = { :col_sep => "\t" }
  sdfb_admin_id = User.first.id

  # Add all of the Group Category data from the dump
  CSV.foreach(Rails.root.join('lib', 'data', 'group_categories.tsv'), tsv_options) do |line|
    GroupCategory.where(
      id:              line[0],
      name:            line[1],
      is_approved:     true,
      created_by:      sdfb_admin_id,
      approved_by:     sdfb_admin_id.to_s
    ).first_or_create!
  end
  ActiveRecord::Base.connection.reset_pk_sequence!("group_categories")

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
end

When(/^I create Francis Bacon with his known ID$/) do
  francis = Person.where(
    id: 10000473,
    first_name: 'Francis',
    last_name: 'Bacon',
    created_by: @sdfbadmin.id,
    gender: 'male',
    birth_year_type: 'IN',
    ext_birth_year: '1561',
    death_year_type: 'IN',
    ext_death_year: '1626',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

Then(/^Francis Bacon is persisted$/) do
  expect(Person.last.id).to eq 10000473
  expect(Person.last.first_name).to eq 'Francis'
end

Given(/^Francis Bacon has already been created$/) do
  @francis = Person.where(
    id: 10000473,
    first_name: 'Francis',
    last_name: 'Bacon',
    created_by: @sdfbadmin.id,
    gender: 'male',
    birth_year_type: 'IN',
    ext_birth_year: '1561',
    death_year_type: 'IN',
    ext_death_year: '1626',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

Given(/^Anne Bacon has already been created$/) do
  @anne = Person.where(
    first_name: 'Anne',
    last_name: 'Bacon',
    created_by: @sdfbadmin.id,
    gender: 'female',
    birth_year_type: 'IN',
    ext_birth_year: '1528',
    death_year_type: 'IN',
    ext_death_year: '1610',
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

When(/^I create a relationship between Anne and Francis$/) do
  @relationship = Relationship.where(
    person1_index: @anne.id,
    person2_index: @francis.id,
    original_certainty: 100,
    created_by: User.first,
    approved_by: @sdfbadmin.id,
    is_approved: true
  ).first_or_create!
end

Then(/^the relationship is persisted$/) do
  expect(Relationship.last.person1_index).to eq @anne.id
  expect(Relationship.last.person2_index).to eq @francis.id
end
