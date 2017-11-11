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
			can :create, [Group, GroupAssignment,  Relationship,  GroupCatAssign, GroupCategory]

			# Curators can view all elements regardless of whether they are approved
			can :show, :all
			
			# Curators can edit everything except other users.
			# Curators can edit and approve groups, relationships, people, and group assignments, user group contributions, user person contributions, and user relationship contributions, group category assignments
			can [:edit, :update], [Group, GroupAssignment,  Relationship,   GroupCatAssign, RelCatAssign]

			# Curators can only edit their own information
			can [:edit, :update], User do |x|  
				x.id == user.id
			end

			can :destroy, [ GroupAssignment]

			# Curators can list all groups, people, and relationships
			can :index, [Group, GroupAssignment,  Relationship,   GroupCatAssign, RelCatAssign]

			# A user can view search results
			can :search, Group

			# Curators can view search results
			can :search, Relationship
			
		elsif (user.user_type == "Standard") 
			#  A user can create users, groups, group assignments, people, relationships, user group contributions, user person contributions, and user relationship contributions
			can [:new, :create], [Group, GroupAssignment,  Relationship, ]

			# A user can view all elements that are approved
			can :show, [Group, GroupAssignment,  Relationship,   RelationshipCategory, GroupCategory, RelCatAssign, GroupCatAssign], :is_approved => true
			
			# A user can see the group that they created even if it was not approved
			can :show, Group do |x|
				x.created_by == user.id 
			end

			# A user can see the GroupAssignment that they created even if it was not approved
			can :show, GroupAssignment do |x|
				x.created_by == user.id 
			end


			# A user can see the Relationship that they created even if it was not approved
			can :show, Relationship do |x|
				x.created_by == user.id 
			end

			# A user can list all groups, people, relationships, relationship types
			can :index, [Group,  Relationship]

			# A user can view search results
			can :search, Group

			# Curators can view search results
			can :search, Relationship


			# Make sure that all users can use the tabs on the people show page
			can :reroute_relationship_form, Relationship

		else
			
			# Anyone can list all groups, people, relationships, relationship types
			can :index, [Group,  Relationship]

			# Anyone can view search results
			can :search, Group


			# Curators can view search results
			can :search, Relationship

			# Anyone can view the details of a groups, people, relationships, relationship types
			can :show, [Group,  Relationship], :is_approved => true

		end
	end
end
