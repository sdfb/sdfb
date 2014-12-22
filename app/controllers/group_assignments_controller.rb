class GroupAssignmentsController < ApplicationController
  # GET /group_assignments
  # GET /group_assignments.json

  # before_filter :check_login
  before_filter :check_login, :only => [:new, :edit]
  authorize_resource
  
  def index
    @group_assignments_approved = GroupAssignment.all_approved

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @group_assignments }
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

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group_assignment }
    end
  end

  # GET /group_assignments/1/edit
  def edit
    @group_assignment = GroupAssignment.find(params[:id])
  end

  # POST /group_assignments
  # POST /group_assignments.json
  def create
    @group_assignment = GroupAssignment.new(params[:group_assignment])

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

  # PUT /group_assignments/1
  # PUT /group_assignments/1.json
  def update
    @group_assignment = GroupAssignment.find(params[:id])

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

  # DELETE /group_assignments/1
  # DELETE /group_assignments/1.json
  # def destroy
  #   @group_assignment = GroupAssignment.find(params[:id])
  #   @group_assignment.destroy

  #   respond_to do |format|
  #     format.html { redirect_to group_assignments_url }
  #     format.json { head :no_content }
  #   end
  # end
end
