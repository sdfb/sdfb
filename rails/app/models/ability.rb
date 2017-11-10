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

			can :destroy, [UserRelContrib, GroupAssignment]

			# Curators can list all groups, people, and relationships
			can :index, [Group, GroupAssignment, Person, Relationship, RelationshipType, UserGroupContrib, UserPersonContrib, UserRelContrib, GroupCatAssign, RelCatAssign]

			# A user can view search results
			can :search, Group

			# Curators can view search results
			can :search, Person

			# Curators can view search results
			can :search, Relationship


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


			# Make sure that all users can use the tabs on the people show page
			can :membership, Person
			can :relationships, Person
			can :notes, Person
			can :reroute_relationship_form, Relationship

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

			# Make sure that all users can use the tabs on the people show page
			can :membership, Person
			can :relationships, Person
			can :notes, Person
		end
	end
end
