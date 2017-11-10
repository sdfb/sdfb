class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json

  load_and_authorize_resource
  
  def index
    @groups_approved = Group.all_approved.order_by_sdfb_id.order_by_sdfb_id.paginate(:page => params[:groups_approved_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end


  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.select("id, name, description, start_date_type, start_year, end_date_type, end_year, justification, created_at, created_by, is_approved, is_active, approved_by, approved_on, is_rejected").find(params[:id])
    @user_group_contribs = UserGroupContrib.all_for_group(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:user_group_contribs_page]).per_page(100)
    @people = GroupAssignment.all_for_group(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:people_page]).per_page(100)
    @group_cat_assigns_approved = GroupCatAssign.for_group(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:group_cat_assigns_approved_page]).per_page(100)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @is_approved = @group.is_approved
    #authorize! :edit, @group
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  def search
    @query = params[:query]
    unless @query.blank?
      if logged_in? == true && (current_user.user_type == "Admin" || current_user.user_type == "Curator")
        @all_results = Group.search_all(@query)
      else
        @all_results = Group.search_approved(@query)
      end
    end
  end
end
