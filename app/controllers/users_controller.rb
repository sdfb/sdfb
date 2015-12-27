class UsersController < ApplicationController
  # GET /users
  # GET /users.json

  # before_filter :check_login
  # before_filter :check_login, :only => [:index, :show, :edit]
  # authorize_resource
  
  load_and_authorize_resource

  def index
    @active_users = User.active.order_by_sdfb_id.paginate(:page => params[:active_users_page]).per_page(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    #authorize! :edit, @user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to new_session_path, notice: 'Signed up!' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def my_contributions
    @user_rel_contribs = UserRelContrib.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:user_rel_contribs_page]).per_page(5)
    @user_person_contribs = UserPersonContrib.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:user_person_contribs_page]).per_page(5)
    @user_group_contribs = UserGroupContrib.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:user_group_contribs_page]).per_page(5)
    @new_people = Person.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:people_page]).per_page(5)
    @new_groups = Group.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:groups_page]).per_page(5)
    @new_relationships = Relationship.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:relationships_page]).per_page(5)
    @group_assignments = GroupAssignment.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:group_assignments_page]).per_page(5)

    @group_cat_assign = GroupCatAssign.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:group_cat_assigns_page]).per_page(5)
    @group_cats = GroupCategory.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:group_cats_page]).per_page(5)
    @rel_type_cat_assigns = RelCatAssign.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:rel_type_cat_assigns_page]).per_page(5)
    @rel_cats = RelationshipCategory.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:rel_cats_page]).per_page(5)
    @rel_types = RelationshipType.for_user(current_user.id).order_by_sdfb_id.paginate(:page => params[:rel_types_page]).per_page(5)
  end

  def all_inactive
    @inactive_people = Person.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_people_page]).per_page(5)
    @inactive_groups = Group.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_groups_page]).per_page(5)
    @inactive_relationships = Relationship.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_relationships_page]).per_page(5)
    @inactive_group_assigns = GroupAssignment.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_group_assigns_page]).per_page(5)
    @inactive_user_group_contribs = UserGroupContrib.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_user_group_contribs_page]).per_page(5)
    @inactive_user_rel_contribs = UserRelContrib.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_user_rel_contribs_page]).per_page(5)
    @inactive_user_person_contribs = UserPersonContrib.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_user_person_contribs_page]).per_page(5)

    @inactive_group_cat_assign = GroupCatAssign.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_group_cat_assigns_page]).per_page(5)
    @inactive_group_cats = GroupCategory.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_group_cats_page]).per_page(5)
    @inactive_rel_type_cat_assigns = RelCatAssign.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_rel_type_cat_assigns_page]).per_page(5)
    @inactive_rel_cats = RelationshipCategory.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_rel_cats_page]).per_page(5)
    @inactive_rel_types = RelationshipType.all_inactive.order_by_sdfb_id.paginate(:page => params[:inactive_rel_types_page]).per_page(5)
  
    @inactive_users = User.all_inactive.paginate(:page => params[:inactive_users_page]).per_page(5)
  end 

  def all_unapproved
    @unapproved_people = Person.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_people_page]).per_page(5)
    @unapproved_groups = Group.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_groups_page]).per_page(5)
    @unapproved_relationships = Relationship.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_relationships_page]).per_page(5)
    @unapproved_group_assigns = GroupAssignment.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_group_assigns_page]).per_page(5)
    @unapproved_user_group_contribs = UserGroupContrib.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_user_group_contribs_page]).per_page(5)
    @unapproved_user_rel_contribs = UserRelContrib.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_user_rel_contribs_page]).per_page(5)
    @unapproved_user_person_contribs = UserPersonContrib.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_user_person_contribs_page]).per_page(5)
  
    @unapproved_group_cat_assign = GroupCatAssign.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_group_cat_assigns_page]).per_page(5)
    @unapproved_group_cats = GroupCategory.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_group_cats_page]).per_page(5)
    @unapproved_rel_type_cat_assigns = RelCatAssign.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_rel_type_cat_assigns_page]).per_page(5)
    @unapproved_rel_cats = RelationshipCategory.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_rel_cats_page]).per_page(5)
    @unapproved_rel_types = RelationshipType.all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_rel_types_page]).per_page(5)
  end

  def all_rejected
    @rejected_people = Person.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_people_page]).per_page(5)
    @rejected_groups = Group.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_groups_page]).per_page(5)
    @rejected_relationships = Relationship.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_relationships_page]).per_page(5)
    @rejected_group_assigns = GroupAssignment.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_group_assigns_page]).per_page(5)
    @rejected_user_group_contribs = UserGroupContrib.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_user_group_contribs_page]).per_page(5)
    @rejected_user_rel_contribs = UserRelContrib.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_user_rel_contribs_page]).per_page(5)
    @rejected_user_person_contribs = UserPersonContrib.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_user_person_contribs_page]).per_page(5)
  
    @rejected_group_cat_assign = GroupCatAssign.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_group_cat_assigns_page]).per_page(5)
    @rejected_group_cats = GroupCategory.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_group_cats_page]).per_page(5)
    @rejected_rel_type_cat_assigns = RelCatAssign.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_rel_type_cat_assigns_page]).per_page(5)
    @rejected_rel_cats = RelationshipCategory.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_rel_cats_page]).per_page(5)
    @rejected_rel_types = RelationshipType.all_rejected.order_by_sdfb_id.paginate(:page => params[:rejected_rel_types_page]).per_page(5)
  end

  def all_recent
    @recent_people = Person.all_recent.all_approved.paginate(:page => params[:recent_people_page]).per_page(5)
    @recent_groups = Group.all_recent.all_approved.paginate(:page => params[:recent_groups_page]).per_page(5)
    @recent_relationships = Relationship.all_recent.all_approved.paginate(:page => params[:recent_relationships_page]).per_page(5)
    @recent_group_assigns = GroupAssignment.all_recent.all_approved.paginate(:page => params[:recent_group_assigns_page]).per_page(5)
    @recent_user_group_contribs = UserGroupContrib.all_recent.all_approved.paginate(:page => params[:recent_user_group_contribs_page]).per_page(5)
    @recent_user_rel_contribs = UserRelContrib.all_recent.all_approved.paginate(:page => params[:recent_user_rel_contribs_page]).per_page(5)
    @recent_user_person_contribs = UserPersonContrib.all_recent.all_approved.paginate(:page => params[:recent_user_person_contribs_page]).per_page(5)

    @recent_group_cat_assign = GroupCatAssign.all_recent.all_approved.paginate(:page => params[:recent_group_cat_assigns_page]).per_page(5)
    @recent_group_cats = GroupCategory.all_recent.all_approved.paginate(:page => params[:recent_group_cats_page]).per_page(5)
    @recent_rel_type_cat_assigns = RelCatAssign.all_recent.all_approved.paginate(:page => params[:recent_rel_type_cat_assigns_page]).per_page(5)
    @recent_rel_cats = RelationshipCategory.all_recent.all_approved.paginate(:page => params[:recent_rel_cats_page]).per_page(5)
    @recent_rel_types = RelationshipType.all_recent.all_approved.paginate(:page => params[:recent_rel_types_page]).per_page(5)
  end

  def export_users
    @all_users = User.active
    if (current_user.user_type == "Admin")
      users_csv = CSV.generate do |csv|
        csv << ["SDFB User ID", "Prefix", "First Name", "Last Name", "User Type", "Username", "Email", "Orcid", "Affiliation", "About", "Created At"]
        @all_users.each do |user|
          csv << [user.id, user.prefix, user.first_name, user.last_name, user.user_type, user.username, user.email, user.orcid, user.affiliation, user.about_description, user.created_at]
        end
      end
    end
    send_data(users_csv, :type => 'text/csv', :filename => 'SDFB_Users.csv')
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
