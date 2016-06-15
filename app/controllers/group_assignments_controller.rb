class GroupAssignmentsController < ApplicationController
  # GET /group_assignments
  # GET /group_assignments.json

  # before_filter :check_login
  # before_filter :check_login, :only => [:new, :edit]
  # authorize_resource

  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  load_and_authorize_resource
  
  def index
    @group_assignments_approved = GroupAssignment.all_approved.order_by_sdfb_id.paginate(:page => params[:group_assignments_page]).per_page(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_assignments }
    end
  end

  def get_autocomplete_items(parameters)
    if ((current_user.user_type == "Admin") || (current_user.user_type == "Curator"))
      active_record_get_autocomplete_items(parameters).where("is_rejected is false")
    else
      active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
    end
  end

  # GET /group_assignments/1
  # GET /group_assignments/1.json
  def show
    @group_assignment = GroupAssignment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group_assignment }
    end
  end

  # GET /group_assignments/new
  # GET /group_assignments/new.json
  def new
    @group_assignment = GroupAssignment.new
    @personOptions = Person.all_approved.alphabetical
    @groupOptions = Group.all_approved.alphabetical
    @person_id = params[:person_id]
    @group_id = params[:group_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_assignment }
    end
  end

  def new_2
    @group_assignment = GroupAssignment.new
    @personOptions = Person.all_approved.alphabetical
    @groupOptions = Group.all_approved.alphabetical
    @group_id = params[:group_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_assignment }
    end
  end

  # GET /group_assignments/1/edit
  def edit
    @group_assignment = GroupAssignment.find(params[:id])
    @personOptions = Person.all_approved.alphabetical
    @groupOptions = Group.all_approved.alphabetical
    @is_approved = @group_assignment.is_approved
    #authorize! :edit, @group_assignment
  end

  # POST /group_assignments
  # POST /group_assignments.json
  def create
    @group_assignment = GroupAssignment.new(params[:group_assignment])
    @personOptions = Person.all_approved.alphabetical
    @groupOptions = Group.all_approved.alphabetical

    respond_to do |format|
      if @group_assignment.save
        format.html { redirect_to @group_assignment, notice: 'Group assignment was successfully created.' }
        format.json { render json: @group_assignment, status: :created, location: @group_assignment }
      else
        format.html { render action: "new" }
        format.json { render json: @group_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_2
    @group_assignment = GroupAssignment.new(params[:group_assignment])
    @personOptions = Person.all_approved.alphabetical
    @groupOptions = Group.all_approved.alphabetical

    respond_to do |format|
      if @group_assignment.save
        format.html { redirect_to @group_assignment, notice: 'Group assignment was successfully created.' }
        format.json { render json: @group_assignment, status: :created, location: @group_assignment }
      else
        format.html { render action: "new_2" }
        format.json { render json: @group_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /group_assignments/1
  # PUT /group_assignments/1.json
  def update
    @group_assignment = GroupAssignment.find(params[:id])
    @personOptions = Person.all_approved.alphabetical
    @groupOptions = Group.all_approved

    respond_to do |format|
      if @group_assignment.update_attributes(params[:group_assignment])
        format.html { redirect_to @group_assignment, notice: 'Group assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_group_assignments
    @all_group_assigns_approved =GroupAssignment.all_approved
    @all_group_assigns = GroupAssignment.all_active_unrejected
    if (current_user.user_type == "Admin")
      group_assigns_csv = CSV.generate do |csv|
          csv << ["SDFB Group Assignment ID", "Group ID", "Person ID", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_group_assigns.each do |group_assign|
              csv << [group_assign.id, group_assign.group_id,
              group_assign.person_id, 
              group_assign.start_date_type, group_assign.start_month, group_assign.start_day,
              group_assign.start_year, group_assign.end_date_type,  group_assign.end_month,
              group_assign.end_day, group_assign.end_year,
              group_assign.created_by, group_assign.created_at,
              group_assign.is_approved, group_assign.approved_by, group_assign.approved_on]
          end
      end
    else
      group_assigns_csv = CSV.generate do |csv|
        csv << ["SDFB Group Assignment ID", "Group ID", "Person ID", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_group_assigns_approved.each do |group_assign|
            csv << [group_assign.id, group_assign.group_id,
            group_assign.person_id, 
            group_assign.start_date_type, group_assign.start_month, group_assign.start_day,
            group_assign.start_year, group_assign.end_date_type,  group_assign.end_month,
            group_assign.end_day, group_assign.end_year]
        end
      end
    end
    send_data(group_assigns_csv, :type => 'text/csv', :filename => 'SDFB_GroupAssignments.csv')
  end

  # DELETE /group_assignments/1
  # DELETE /group_assignments/1.json
  def destroy
    @group_assignment = GroupAssignment.find(params[:id])
    @group_assignment.destroy

    respond_to do |format|
      format.html { redirect_to group_assignments_url }
      format.json { head :no_content }
    end
  end
end
