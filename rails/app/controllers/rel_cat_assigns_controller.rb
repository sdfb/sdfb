class RelCatAssignsController < ApplicationController
  # GET /rel_cat_assigns
  # GET /rel_cat_assigns.json

  load_and_authorize_resource
  
  def index
    @rel_cat_assigns_approved = RelCatAssign.all_approved.order_by_sdfb_id.paginate(:page => params[:rel_cat_assigns_approved_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rel_cat_assigns }
    end
  end

  # GET /rel_cat_assigns/1
  # GET /rel_cat_assigns/1.json
  def show
    @rel_cat_assign = RelCatAssign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rel_cat_assign }
    end
  end

  # GET /rel_cat_assigns/new
  # GET /rel_cat_assigns/new.json
  def new
    @rel_cat_assign = RelCatAssign.new
    @relTypeOptions = RelationshipType.all_approved.alphabetical
    @rel_type_id = params[:rel_type_id]
    @relCatOptions = RelationshipCategory.all_approved.alphabetical
    @rel_cat_id = params[:rel_cat_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rel_cat_assign }
    end
  end

  # GET /rel_cat_assigns/1/edit
  def edit
    @rel_cat_assign = RelCatAssign.find(params[:id])
    @relTypeOptions = RelationshipType.all_approved.alphabetical
    @rel_type_id = params[:rel_type_id]
    @relCatOptions = RelationshipCategory.all_approved.alphabetical
    @rel_cat_id = params[:rel_cat_id]
    @is_approved = @rel_cat_assign.is_approved
    #authorize! :edit, @rel_cat_assign
  end

  # POST /rel_cat_assigns
  # POST /rel_cat_assigns.json
  def create
    @rel_cat_assign = RelCatAssign.new(params[:rel_cat_assign])
    @relTypeOptions = RelationshipType.all_approved.alphabetical
    @rel_type_id = params[:rel_type_id]
    @relCatOptions = RelationshipCategory.all_approved.alphabetical
    @rel_cat_id = params[:rel_cat_id]

    respond_to do |format|
      if @rel_cat_assign.save
        format.html { redirect_to @rel_cat_assign, notice: 'Rel cat assign was successfully created.' }
        format.json { render json: @rel_cat_assign, status: :created, location: @rel_cat_assign }
      else
        format.html { render action: "new" }
        format.json { render json: @rel_cat_assign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rel_cat_assigns/1
  # PUT /rel_cat_assigns/1.json
  def update
    @rel_cat_assign = RelCatAssign.find(params[:id])
    @relTypeOptions = RelationshipType.all_approved
    @rel_type_id = params[:rel_type_id]
    @relCatOptions = RelationshipCategory.all_approved
    @rel_cat_id = params[:rel_cat_id]

    respond_to do |format|
      if @rel_cat_assign.update_attributes(params[:rel_cat_assign])
        format.html { redirect_to @rel_cat_assign, notice: 'Rel cat assign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rel_cat_assign.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /rel_cat_assigns/1
  # DELETE /rel_cat_assigns/1.json
  def destroy
    @rel_cat_assign = RelCatAssign.find(params[:id])
    @rel_cat_assign.destroy

    respond_to do |format|
      format.html { redirect_to rel_cat_assigns_url }
      format.json { head :no_content }
    end
  end
end
