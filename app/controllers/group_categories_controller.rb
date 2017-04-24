class GroupCategoriesController < ApplicationController
  # GET /group_categories
  # GET /group_categories.json

  load_and_authorize_resource

  def index
    @group_categories_approved = GroupCategory.all_approved.order_by_sdfb_id.paginate(:page => params[:group_category_approved_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_categories }
    end
  end

  # GET /group_categories/1
  # GET /group_categories/1.json
  def show
    @group_category = GroupCategory.find(params[:id])
    @group_cat_assigns_approved = GroupCatAssign.for_group_category(params[:id]).all_approved.order_by_sdfb_id.paginate(:page => params[:group_cat_assigns_approved_page]).per_page(100)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group_category }
    end
  end

  # GET /group_categories/new
  # GET /group_categories/new.json
  def new
    @group_category = GroupCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_category }
    end
  end

  # GET /group_categories/1/edit
  def edit
    @group_category = GroupCategory.find(params[:id])
    @is_approved = @group_category.is_approved
    #authorize! :edit, @group_category
  end

  # POST /group_categories
  # POST /group_categories.json
  def create
    @group_category = GroupCategory.new(params[:group_category])

    respond_to do |format|
      if @group_category.save
        format.html { redirect_to @group_category, notice: 'Group category was successfully created.' }
        format.json { render json: @group_category, status: :created, location: @group_category }
      else
        format.html { render action: "new" }
        format.json { render json: @group_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /group_categories/1
  # PUT /group_categories/1.json
  def update
    @group_category = GroupCategory.find(params[:id])

    respond_to do |format|
      if @group_category.update_attributes(params[:group_category])
        format.html { redirect_to @group_category, notice: 'Group category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_group_categories
    @all_group_categories_approved = GroupCategory.all_approved
    @all_group_categories = GroupCategory.all_active_unrejected
    if (current_user.user_type == "Admin")
      group_categories_csv = CSV.generate do |csv|
        csv << ["SDFB Group Category ID", "Group Category Name", "Description", "Created By", "Created At", "Is Approved?", "Approved By ID", "Approved On"]
        @all_group_categories.each do |group_category|
           csv << [group_category.id, group_category.name,
           group_category.description, group_category.created_by, group_category.created_at,
           group_category.is_approved, group_category.approved_by, group_category.approved_on]
        end
      end
    else
      group_categories_csv = CSV.generate do |csv|
        csv << ["SDFB Group Category ID", "Group Category Name", "Description", "Created By", "Created At"]
        @all_group_categories_approved.each do |group_category|
          csv << [group_category.id, group_category.name,
          group_category.description, group_category.created_by, group_category.created_at]
        end
      end
    end
    send_data(group_categories_csv, :type => 'text/csv', :filename => 'SDFB_GroupCategories.csv')
  end

  # DELETE /group_categories/1
  # DELETE /group_categories/1.json
  def destroy
    @group_category = GroupCategory.find(params[:id])
    @group_category.destroy

    respond_to do |format|
      format.html { redirect_to group_categories_url }
      format.json { head :no_content }
    end
  end
end
