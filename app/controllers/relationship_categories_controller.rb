class RelationshipCategoriesController < ApplicationController
  # GET /relationship_categories
  # GET /relationship_categories.json

  load_and_authorize_resource
  
  def index
    @relationship_categories = RelationshipCategory.all_approved.order_by_sdfb_id.paginate(:page => params[:rel_category_approved_page]).per_page(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @relationship_categories }
    end
  end

  # GET /relationship_categories/1
  # GET /relationship_categories/1.json
  def show
    @relationship_category = RelationshipCategory.find(params[:id])
    @rel_cat_assigns_approved = RelCatAssign.all_approved.for_rel_cat(params[:id]).order_by_sdfb_id.paginate(:page => params[:rel_cat_assigns_approved_page]).per_page(30)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @relationship_category }
    end
  end

  # GET /relationship_categories/new
  # GET /relationship_categories/new.json
  def new
    @relationship_category = RelationshipCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @relationship_category }
    end
  end

  # GET /relationship_categories/1/edit
  def edit
    @relationship_category = RelationshipCategory.find(params[:id])
    @is_approved = @relationship_category.is_approved
    #authorize! :edit, @relationship_category
  end

  # POST /relationship_categories
  # POST /relationship_categories.json
  def create
    @relationship_category = RelationshipCategory.new(params[:relationship_category])

    respond_to do |format|
      if @relationship_category.save
        format.html { redirect_to @relationship_category, notice: 'Relationship category was successfully created.' }
        format.json { render json: @relationship_category, status: :created, location: @relationship_category }
      else
        format.html { render action: "new" }
        format.json { render json: @relationship_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /relationship_categories/1
  # PUT /relationship_categories/1.json
  def update
    @relationship_category = RelationshipCategory.find(params[:id])

    respond_to do |format|
      if @relationship_category.update_attributes(params[:relationship_category])
        format.html { redirect_to @relationship_category, notice: 'Relationship category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @relationship_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_rel_cats
    @all_relationship_categories_approved = RelationshipCategory.all_approved
    @all_relationship_categories = RelationshipCategory.all_active_unrejected
    if (current_user.user_type == "Admin")
      relationship_categories_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Category ID", "Relationship Category Name", "Description", "Created By", "Created At", "Is Approved?", "Approved By ID", "Approved On"]
        @all_relationship_categories.each do |relationship_category|
          csv << [relationship_category.id, relationship_category.name,
          relationship_category.description, relationship_category.created_by, relationship_category.created_at,
          relationship_category.is_approved, relationship_category.approved_by, relationship_category.approved_on]
        end
      end
    else
      relationship_categories_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Category ID", "Relationship Category Name", "Description", "Created By", "Created At"]
        @all_relationship_categories_approved.each do |relationship_category|
          csv << [relationship_category.id, relationship_category.name,
          relationship_category.description, relationship_category.created_by, relationship_category.created_at]
        end
      end
    end
    send_data(relationship_categories_csv, :type => 'text/csv', :filename => 'SDFB_RelationshipCategories.csv')
  end

  # DELETE /relationship_categories/1
  # DELETE /relationship_categories/1.json
  def destroy
    @relationship_category = RelationshipCategory.find(params[:id])
    @relationship_category.destroy

    respond_to do |format|
      format.html { redirect_to relationship_categories_url }
      format.json { head :no_content }
    end
  end
end
