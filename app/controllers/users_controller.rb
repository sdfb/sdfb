class UsersController < ApplicationController
  # GET /users
  # GET /users.json

  # before_filter :check_login
  # before_filter :check_login, :only => [:index, :show, :edit]
  # authorize_resource
  
  load_and_authorize_resource

  def index
    @inactive_users = User.inactive.paginate(:page => params[:inactive_users_page]).per_page(20)
    @active_users = User.active.paginate(:page => params[:active_users_page]).per_page(20)

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

  def dashboard
    @unapproved_people = Person.all_unapproved.paginate(:page => params[:unapproved_people_page]).per_page(5)
    @unapproved_groups = Group.all_unapproved.paginate(:page => params[:unapproved_groups_page]).per_page(5)
    @unapproved_relationships = Relationship.all_unapproved.paginate(:page => params[:unapproved_relationships_page]).per_page(5)
    @unapproved_group_assigns = GroupAssignment.all_unapproved.paginate(:page => params[:unapproved_group_assigns_page]).per_page(5)
    @unapproved_user_group_contribs = UserGroupContrib.all_unapproved.paginate(:page => params[:unapproved_user_group_contribs_page]).per_page(5)
    @unapproved_user_rel_contribs = UserRelContrib.all_unapproved.paginate(:page => params[:unapproved_user_rel_contribs_page]).per_page(5)
    @unapproved_user_person_contribs = UserPersonContrib.all_unapproved.paginate(:page => params[:unapproved_user_person_contribs_page]).per_page(5)
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # def destroy
  #   @user = User.find(params[:id])
  #   @user.destroy

  #   respond_to do |format|
  #     format.html { redirect_to users_url }
  #     format.json { head :no_content }
  #   end
  # end
end
