class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json

  # before_filter :check_login
  # before_filter :check_login, :only => [:new, :edit]
  # authorize_resource

  load_and_authorize_resource
  
  def index
    @groups_approved = Group.all_approved.paginate(:page => params[:groups_approved_page]).per_page(20)
    @groups_unapproved = Group.all_unapproved.paginate(:page => params[:groups_unapproved_page]).per_page(20)


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])
    @user_group_contribs = UserGroupContrib.all_for_group(params[:id]).all_approved.paginate(:page => params[:user_group_contribs_page]).per_page(20)
    @people = GroupAssignment.all_for_group(params[:id]).all_approved.paginate(:page => params[:people_page]).per_page(20)
    @group_cat_assigns_approved = GroupCatAssign.for_group(params[:id]).all_approved.paginate(:page => params[:group_cat_assigns_approved_page]).per_page(20)

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
  # def destroy
  #   @group = Group.find(params[:id])
  #   @group.destroy

  #   respond_to do |format|
  #     format.html { redirect_to groups_url }
  #     format.json { head :no_content }
  #   end
  # end

  def search
    @query = params[:query]
    if @query != "" 
      if ((current_user.user_type == "Admin") || (current_user.user_type == "Curator"))
        @all_results1 = Group.search_all(@query)
      else
        @all_results1 = Group.search_approved(@query)
      end
      @all_results = @all_results1.paginate(:page => params[:all_results_page], :per_page => 20)
    end
  end

  def export_groups
    @all_groups_approved = Group.all_approved
    @all_groups = Group.all
    if (current_user.user_type == "Admin")
      group_csv = CSV.generate do |csv|
        csv << ["SDFB Group ID", "Name", "Description", "Start Year", "End Year", "Members List (Name with SDFB Person ID)", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_groups.each do |group|
          csv << [group.id, group.name, group.description, group.start_year, group.end_year, group.person_list, group.justification, group.created_by, User.find(group.created_by).get_person_name, group.created_at,
            group.is_approved, group.approved_by, User.find(group.approved_by).get_person_name, group.approved_on]
        end
      end
    else
      group_csv = CSV.generate do |csv|
        csv << ["SDFB Group ID", "Name", "Description", "Start Year", "End Year", "Members List (Name with SDFB Person ID)"]
        @all_people_approved.each do |group|
          csv << [group.id, group.name, group.description, group.start_year, group.end_year, group.person_list]
        end
      end
    end
    send_data(group_csv, :type => 'text/csv', :filename => 'SDFB_groups.csv')
  end
end
