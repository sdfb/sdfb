class Ability
	include CanCan::Ability

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def initialize(user)
		user ||= User.new
		
		if (user.user_type == "Admin") 
			# If you're an admin, you have the power to create and edit everything
			can :manage, :all
		elsif (user.user_type == "Curator")
			# Curators can create users, groups, group assignments, people, relationships, user group contributions, user person contributions, user relationship contributions, group category assignments
			can :create, [User, Group, GroupAssignment, Person, Relationship, UserGroupContrib, UserPersonContrib, UserRelContrib, GroupCatAssign, GroupCategory]

			# Curators can view all elements regardless of whether they are approved
			can :show, :all
			
			# Curators can edit everything except other users.
			# Curators can edit and approve groups, relationships, people, and group assignments, user group contributions, user person contributions, and user relationship contributions, group category assignments
			can [:edit, :update], [Group, GroupAssignment, Person, Relationship, UserGroupContrib, UserPersonContrib, UserRelContrib, GroupCatAssign, RelCatAssign]

			# Curators can only edit their own information
			can [:edit, :update], User do |x|  
				x.id == user.id
			end

			# Curators can list all groups, people, and relationships
			can :index, [Group, GroupAssignment, Person, Relationship, RelationshipType, UserGroupContrib, UserPersonContrib, UserRelContrib, GroupCatAssign, RelCatAssign]

			# A user can view search results
			can :search, Group

			# Curators can view search results
			can :search, Person

			# Curators can view search results
			can :search, Relationship

			# A user can download groups data
			can :export_groups, Group

			# A user can download people data
			can :export_people, Person

			# A user can download group assginment data
			can :export_group_assignments, GroupAssignment

			# A user can download relationship type assignment data
			can :export_rel_type_assigns, UserRelContrib
			can :export_rel_type_assigns_00000_20000, UserRelContrib
			can :export_rel_type_assigns_20001_40000, UserRelContrib
			can :export_rel_type_assigns_40001_60000, UserRelContrib
			can :export_rel_type_assigns_60001_80000, UserRelContrib
			can :export_rel_type_assigns_80001_100000, UserRelContrib
			can :export_rel_type_assigns_100001_120000, UserRelContrib
			can :export_rel_type_assigns_120001_140000, UserRelContrib
			can :export_rel_type_assigns_140001_160000, UserRelContrib
			can :export_rel_type_assigns_160001_180000, UserRelContrib
			can :export_rel_type_assigns_greater_than_180000, UserRelContrib

			# A user can download relationship data
			can :export_relationships, Relationship
			can :export_rels_for_rels_100000000_100020000, Relationship
			can :export_rels_for_rels_100020001_100040000, Relationship
			can :export_rels_for_rels_100040001_100060000, Relationship
			can :export_rels_for_rels_100060001_100080000, Relationship
			can :export_rels_for_rels_100080001_100100000, Relationship
			can :export_rels_for_rels_100100001_100120000, Relationship
			can :export_rels_for_rels_100120001_100140000, Relationship
			can :export_rels_for_rels_100140001_100160000, Relationship
			can :export_rels_for_rels_100160001_100180000, Relationship
			can :export_rels_for_rels_greater_than_100180000, Relationship

			# A user can export category assignment records
			can :export_group_cat_assigns, GroupCatAssign

			# A user can export relationship category assignment records
			can :export_rel_cat_assigns, RelCatAssign

			# A user can export user group contributions records
			can :export_group_notes, UserGroupContrib

			# A user can export user person contributions records
			can :export_people_notes, UserPersonContrib

			# A user can export group category records
			can :export_group_categories, GroupCategory

			# A user can export relationship category records
			can :export_rel_cats, RelationshipCategory

			# A user can export relationship type records
			can :export_rel_types, RelationshipType

			# A user can export all relevant records to the relationship category assignments
			can :export_rel_cat_assign_list, RelCatAssign

			# A user can export all relevant records to the group category assignments
			can :export_group_cat_assign_list, GroupCatAssign

			# A user can view their dashboard
			can :my_contributions, User
			can :all_unapproved, User

			# A user can see recent contributions
			can :all_recent, User
			
			# A user can see the autocomplete dropdowns for people and relationships
			can :autocomplete_person_search_names_all, [Relationship, Person, UserRelContrib, GroupAssignment]

			# A user can see the autocomplete dropdowns for groups
			can :autocomplete_group_name, Group

			# Make sure that all users can use the tabs on the people show page
			can :membership, Person
			can :relationships, Person
			can :notes, Person

		elsif (user.user_type == "Standard") 
			#  A user can create users, groups, group assignments, people, relationships, user group contributions, user person contributions, and user relationship contributions
			can [:new, :create], [User, Group, GroupAssignment, Person, Relationship, UserGroupContrib, UserPersonContrib, UserRelContrib]

			# A user can view all elements that are approved
			can :show, User
			can :show, [Group, GroupAssignment, Person, Relationship, UserGroupContrib, UserPersonContrib, UserRelContrib, RelationshipType, RelationshipCategory, GroupCategory, RelCatAssign, GroupCatAssign], :is_approved => true
			
			# A user can see the group that they created even if it was not approved
			can :show, Group do |x|
				x.created_by == user.id 
			end

			# A user can see the GroupAssignment that they created even if it was not approved
			can :show, GroupAssignment do |x|
				x.created_by == user.id 
			end

			# A user can see the Person that they created even if it was not approved
			can :show, Person do |x|
				x.created_by == user.id 
			end

			# A user can see the Relationship that they created even if it was not approved
			can :show, Relationship do |x|
				x.created_by == user.id 
			end

			# A user can see the UserGroupContrib that they created even if it was not approved
			can :show, UserGroupContrib do |x|
				x.created_by == user.id 
			end

			# A user can see the UserPersonContrib that they created even if it was not approved
			can :show, UserPersonContrib do |x|
				x.created_by == user.id 
			end

			# A user can see the UserRelContrib that they created even if it was not approved
			can :show, UserRelContrib do |x|
				x.created_by == user.id 
			end

			# A user can edit and manage their own user_group_contrib, if they created it
			can [:edit, :update], UserGroupContrib do |x|
				x.created_by == user.id 
			end

			# A user can edit and manage their own user_person_contrib, if they created it
			can [:edit, :update], UserPersonContrib do |x|
				x.created_by == user.id 
			end

			# A user can edit and manage their own user_rel_contrib, if they created it
			can [:edit, :update], UserRelContrib do |x|
				x.created_by == user.id 
			end

			# A user can only edit their own information
			can [:show, :edit, :update], User do |x|  
				x.id == user.id
			end

			# A user can list all groups, people, relationships, relationship types
			can :index, [Group, Person, Relationship, RelationshipType]

			# A user can view search results
			can :search, Group

			# A user can view search results
			can :search, Person

			# Curators can view search results
			can :search, Relationship

			# A user can download groups data
			can :export_groups, Group

			# A user can download people data
			can :export_people, Person

			# A user can download relationship data
			can :export_relationships, Relationship
			can :export_rels_for_rels_100000000_100020000, Relationship
			can :export_rels_for_rels_100020001_100040000, Relationship
			can :export_rels_for_rels_100040001_100060000, Relationship
			can :export_rels_for_rels_100060001_100080000, Relationship
			can :export_rels_for_rels_100080001_100100000, Relationship
			can :export_rels_for_rels_100100001_100120000, Relationship
			can :export_rels_for_rels_100120001_100140000, Relationship
			can :export_rels_for_rels_100140001_100160000, Relationship
			can :export_rels_for_rels_100160001_100180000, Relationship
			can :export_rels_for_rels_greater_than_100180000, Relationship
			
			# A user can export relationship type records
			can :export_rel_types, RelationshipType

			# A user can view their dashboard
			can :my_contributions, User

			# A user can see recent contributions
			can :all_recent, User

			# A user can see the autocomplete dropdowns for people and relationships
			can :autocomplete_person_search_names_all, [Relationship, Person, UserRelContrib, GroupAssignment]

			# A user can see the autocomplete dropdowns for groups
			can :autocomplete_group_name, Group

			# Make sure that all users can use the tabs on the people show page
			can :membership, Person
			can :relationships, Person
			can :notes, Person

		else
			# Anyone can sign up
			can [:new, :create], User
			
			# Anyone can list all groups, people, relationships, relationship types
			can :index, [Group, Person, Relationship, RelationshipType]

			# Anyone can view search results
			can :search, Group

			# Anyone can view search results
			can [:update_node_info, :search], Person

			# Curators can view search results
			can :search, Relationship

			# Anyone can view the details of a groups, people, relationships, relationship types
			can :show, [Group, Person, Relationship, RelationshipType], :is_approved => true

			# Anyone can see the autocomplete dropdowns for people and relationships
			can :autocomplete_person_search_names_all, [Relationship, Person, UserRelContrib, GroupAssignment]

			# Anyone can see the autocomplete dropdowns for groups
			can :autocomplete_group_name, Group

			# A user can see recent contributions
			# can :all_recent, User

			# Make sure that all users can use the tabs on the people show page
			can :membership, Person
			can :relationships, Person
			can :notes, Person
		end
	end
end
