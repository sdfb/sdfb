class Ability
  include CanCan::Ability

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def initialize(user)
    user ||= User.new
    
    if user.is_admin 
      # If you're an admin, you have the power to manage everything
      can :manage, :all
    else
      # All users can create users, groups, group assignments, people, relationships, user group contributions, user person contributions, and user relationship contributions
      can :create, [User, Group, GroupAssignment, Person, Relationship, UserGroupContrib, UserPersonContrib, UserRelContrib]
      
      # All users can look at the details of other users, but only edit their own information
      can :show, User
      can [:edit, :update], User do |x|  
        x.id == user.id
      end

      # A user can list all user_group_contribs that they created
      can :index, UserGroupContrib do [usergroupcontrib]
        usergroupcontrib.created_by = user.id
      end
      
      # A user can list all user_person_contribs that they created
      can :index, UserPersonContrib do [userpersoncontrib]
        userpersoncontrib.created_by = user.id
      end

      # A user can list all user_rel_contribs that they created
      can :index, UserRelContrib do [userrelcontrib]
        userrelcontrib.created_by = user.id
      end

      # A user can list all groups that they created
      can :index, Group do [group]
        group.created_by = user.id
      end

      # A user can list all people that they created
      can :index, Person do [person]
        person.created_by = user.id
      end

      # A user can list all relationships that they created
      can :index, Relationship do [relationship]
        relationship.created_by = user.id
      end

      # A user can list all group assignments that they created
      can :index, GroupAssignment do [groupassignment]
        groupassignment.created_by = user.id
      end

      # A user can view all elements
      can :show, [Group, GroupAssignment, Person, Relationship, UserGroupContrib, UserPersonContrib, UserRelContrib]
      
      # A user can edit and manage their own user_group_contrib, if they created it
      can :update, UserGroupContrib do |x|
        x.created_by == user.id 
      end

      # A user can edit and manage their own user_person_contrib, if they created it
      can :update, UserPersonContrib do |x|
        x.created_by == user.id 
      end

      # A user can edit and manage their own user_rel_contrib, if they created it
      can :update, UserRelContrib do |x|
        x.created_by == user.id 
      end 

      # A user can view search results
      can :search, Person

    end
  end
end
