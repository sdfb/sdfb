class UserRelContribsController < ApplicationController
  # GET /user_rel_contribs
  # GET /user_rel_contribs.json

  # before_filter :check_login
  #before_filter :check_login, :only => [:index, :new, :edit]
  
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  load_and_authorize_resource

  def index
    @user_rel_contribs = UserRelContrib.all_approved.paginate(:page => params[:user_rel_contribs_page]).per_page(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_rel_contribs }
    end
  end

  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end

  # GET /user_rel_contribs/1
  # GET /user_rel_contribs/1.json
  def show
    @user_rel_contrib = UserRelContrib.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_rel_contrib }
    end
  end

  # GET /user_rel_contribs/new
  # GET /user_rel_contribs/new.json
  def new
    @user_rel_contrib = UserRelContrib.new
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved.alphabetical

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_rel_contrib }
    end
  end

  # GET /user_rel_contribs/1/edit
  def edit
    @user_rel_contrib = UserRelContrib.find(params[:id])
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved.alphabetical
    @is_approved = @user_rel_contrib.is_approved
    #authorize! :edit, @user_rel_contrib
  end

  # POST /user_rel_contribs
  # POST /user_rel_contribs.json
  def create
    @user_rel_contrib = UserRelContrib.new(params[:user_rel_contrib])
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved.alphabetical

    respond_to do |format|
      if @user_rel_contrib.save
        format.html { redirect_to @user_rel_contrib, notice: 'User rel contrib was successfully created.' }
        format.json { render json: @user_rel_contrib, status: :created, location: @user_rel_contrib }
      else
        format.html { render action: "new" }
        format.json { render json: @user_rel_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_rel_contribs/1
  # PUT /user_rel_contribs/1.json
  def update
    @user_rel_contrib = UserRelContrib.find(params[:id])
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved

    respond_to do |format|
      if @user_rel_contrib.update_attributes(params[:user_rel_contrib])
        format.html { redirect_to @user_rel_contrib, notice: 'User rel contrib was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_rel_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_rel_contribs/1
  # DELETE /user_rel_contribs/1.json
  # def destroy
  #   @user_rel_contrib = UserRelContrib.find(params[:id])
  #   @user_rel_contrib.destroy

  #   respond_to do |format|
  #     format.html { redirect_to user_rel_contribs_url }
  #     format.json { head :no_content }
  #   end
  # end

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to login_url # halts request cycle
    end
  end
end
