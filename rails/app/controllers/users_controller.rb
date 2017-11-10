class UsersController < ApplicationController
  # GET /users
  # GET /users.json

  load_and_authorize_resource

  def index
    @active_users = User.active.order_by_sdfb_id.paginate(:page => params[:active_users_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @points = @user.calculate_points
    @user_rel_contribs = UserRelContrib.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:user_rel_contribs_page]).per_page(5)
    @user_person_contribs = UserPersonContrib.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:user_person_contribs_page]).per_page(5)
    @user_group_contribs = UserGroupContrib.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:user_group_contribs_page]).per_page(5)
    @new_people = Person.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:people_page]).per_page(5)
    @new_groups = Group.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:groups_page]).per_page(5)
    @new_relationships = Relationship.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:relationships_page]).per_page(5)
    @group_assignments = GroupAssignment.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:group_assignments_page]).per_page(5)
    @group_cat_assign = GroupCatAssign.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:group_cat_assigns_page]).per_page(5)
    @group_cats = GroupCategory.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:group_cats_page]).per_page(5)
    @rel_type_cat_assigns = RelCatAssign.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:rel_type_cat_assigns_page]).per_page(5)
    @rel_cats = RelationshipCategory.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:rel_cats_page]).per_page(5)
    @rel_types = RelationshipType.for_user(@user.id).all_approved.order_by_sdfb_id.paginate(:page => params[:rel_types_page]).per_page(5)
    @unapproved_people = Person.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_people_page]).per_page(5)
    @unapproved_groups = Group.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_groups_page]).per_page(5)
    @unapproved_relationships = Relationship.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_relationships_page]).per_page(5)
    @unapproved_group_assigns = GroupAssignment.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_group_assigns_page]).per_page(5)
    @unapproved_user_group_contribs = UserGroupContrib.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_user_group_contribs_page]).per_page(5)
    @unapproved_user_rel_contribs = UserRelContrib.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_user_rel_contribs_page]).per_page(5)
    @unapproved_user_person_contribs = UserPersonContrib.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_user_person_contribs_page]).per_page(5)
    @unapproved_group_cat_assign = GroupCatAssign.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_group_cat_assigns_page]).per_page(5)
    @unapproved_group_cats = GroupCategory.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_group_cats_page]).per_page(5)
    @unapproved_rel_type_cat_assigns = RelCatAssign.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_rel_type_cat_assigns_page]).per_page(5)
    @unapproved_rel_cats = RelationshipCategory.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_rel_cats_page]).per_page(5)
    @unapproved_rel_types = RelationshipType.for_user(@user.id).all_unapproved.order_by_sdfb_id.paginate(:page => params[:unapproved_rel_types_page]).per_page(5)
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
