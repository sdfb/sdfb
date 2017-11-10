class GroupCatAssignsController < ApplicationController
  # GET /group_cat_assigns
  # GET /group_cat_assigns.json

  load_and_authorize_resource
  
  def index
    @group_cat_assigns_approved = GroupCatAssign.all_approved.order_by_sdfb_id.paginate(:page => params[:group_cat_assigns_approved_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_cat_assigns }
    end
  end

  # GET /group_cat_assigns/1
  # GET /group_cat_assigns/1.json
  def show
    @group_cat_assign = GroupCatAssign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group_cat_assign }
    end
  end

  # GET /group_cat_assigns/new
  # GET /group_cat_assigns/new.json
  def new
    @group_cat_assign = GroupCatAssign.new
    @groupOptions = Group.all_approved.alphabetical
    @group_id = params[:group_id]
    @groupCatOptions = GroupCategory.all_approved.alphabetical
    @group_cat_id = params[:group_cat_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_cat_assign }
    end
  end

  # GET /group_cat_assigns/1/edit
  def edit
    @group_cat_assign = GroupCatAssign.find(params[:id])
    @groupOptions = Group.all_approved.alphabetical
    @group_id = params[:group_id]
    @groupCatOptions = GroupCategory.all_approved.alphabetical
    @group_cat_id = params[:group_cat_id]
    @is_approved = @group_cat_assign.is_approved
    #authorize! :edit, @group_cat_assign
  end

  # POST /group_cat_assigns
  # POST /group_cat_assigns.json
  def create
    @group_cat_assign = GroupCatAssign.new(params[:group_cat_assign])
    @groupOptions = Group.all_approved.alphabetical
    @group_id = params[:group_id]
    @groupCatOptions = GroupCategory.all_approved.alphabetical
    @group_cat_id = params[:group_cat_id]

    respond_to do |format|
      if @group_cat_assign.save
        format.html { redirect_to @group_cat_assign, notice: 'Group cat assign was successfully created.' }
        format.json { render json: @group_cat_assign, status: :created, location: @group_cat_assign }
      else
        format.html { render action: "new" }
        format.json { render json: @group_cat_assign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /group_cat_assigns/1
  # PUT /group_cat_assigns/1.json
  def update
    @group_cat_assign = GroupCatAssign.find(params[:id])
    @groupOptions = Group.all_approved
    @group_id = params[:group_id]
    @groupCatOptions = GroupCategory.all_approved
    @group_cat_id = params[:group_cat_id]

    respond_to do |format|
      if @group_cat_assign.update_attributes(params[:group_cat_assign])
        format.html { redirect_to @group_cat_assign, notice: 'Group cat assign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group_cat_assign.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /group_cat_assigns/1
  # DELETE /group_cat_assigns/1.json
  def destroy
    @group_cat_assign = GroupCatAssign.find(params[:id])
    @group_cat_assign.destroy

    respond_to do |format|
      format.html { redirect_to group_cat_assigns_url }
      format.json { head :no_content }
    end
  end
end
