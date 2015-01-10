class RelationshipTypesController < ApplicationController
  # GET /relationship_types
  # GET /relationship_types.json
  
  load_and_authorize_resource
  
  def index
    @relationship_types = RelationshipType.all_approved.paginate(:page => params[:rel_types_approved_page]).per_page(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @relationship_types }
    end
  end

  # GET /relationship_types/1
  # GET /relationship_types/1.json
  def show
    @relationship_type = RelationshipType.find(params[:id])
    @rel_cat_assigns_approved = RelCatAssign.all_approved.for_rel_type(params[:id]).paginate(:page => params[:rel_cat_assigns_approved_page]).per_page(20)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @relationship_type }
    end
  end

  # GET /relationship_types/new
  # GET /relationship_types/new.json
  def new
    @relationship_type = RelationshipType.new
    @relTypeOptions = RelationshipType.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @relationship_type }
    end
  end

  # GET /relationship_types/1/edit
  def edit
    @relationship_type = RelationshipType.find(params[:id])
    @relTypeOptions = RelationshipType.all
    @is_approved = @relationship_type.is_approved
    #authorize! :edit, @relationship_type
  end

  # POST /relationship_types
  # POST /relationship_types.json
  def create
    @relationship_type = RelationshipType.new(params[:relationship_type])
    @relTypeOptions = RelationshipType.all

    respond_to do |format|
      if @relationship_type.save
        format.html { redirect_to @relationship_type, notice: 'Relationship type was successfully created.' }
        format.json { render json: @relationship_type, status: :created, location: @relationship_type }
      else
        format.html { render action: "new" }
        format.json { render json: @relationship_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /relationship_types/1
  # PUT /relationship_types/1.json
  def update
    @relationship_type = RelationshipType.find(params[:id])
    @relTypeOptions = RelationshipType.all

    respond_to do |format|
      if @relationship_type.update_attributes(params[:relationship_type])
        format.html { redirect_to @relationship_type, notice: 'Relationship type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @relationship_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /relationship_types/1
  # DELETE /relationship_types/1.json
  # def destroy
  #   @relationship_type = RelationshipType.find(params[:id])
  #   @relationship_type.destroy

  #   respond_to do |format|
  #     format.html { redirect_to relationship_types_url }
  #     format.json { head :no_content }
  #   end
  # end
end
