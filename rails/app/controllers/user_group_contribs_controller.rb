class UserGroupContribsController < ApplicationController
  # this class is known as "Group Notes" to the user

  # GET /user_group_contribs
  # GET /user_group_contribs.json

  load_and_authorize_resource

  def index
    @user_group_contribs = UserGroupContrib.all_approved.order_by_sdfb_id.paginate(:page => params[:user_group_contribs_page]).per_page(100)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_group_contribs }
    end
  end

  # GET /user_group_contribs/1
  # GET /user_group_contribs/1.json
  def show
    @user_group_contrib = UserGroupContrib.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_group_contrib }
    end
  end

  # GET /user_group_contribs/new
  # GET /user_group_contribs/new.json
  def new
    @user_group_contrib = UserGroupContrib.new
    @groupOptions = Group.all_approved.alphabetical
    @group_id = params[:group_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_group_contrib }
    end
  end

  # GET /user_group_contribs/1/edit
  def edit
    @user_group_contrib = UserGroupContrib.find(params[:id])
    @groupOptions = Group.all_approved.alphabetical
    @is_approved = @user_group_contrib.is_approved
    #authorize! :edit, @user_group_contrib
  end

  # POST /user_group_contribs
  # POST /user_group_contribs.json
  def create
    @user_group_contrib = UserGroupContrib.new(params[:user_group_contrib])
    @groupOptions = Group.all_approved.alphabetical

    respond_to do |format|
      if @user_group_contrib.save
        format.html { redirect_to @user_group_contrib, notice: 'User group contrib was successfully created.' }
        format.json { render json: @user_group_contrib, status: :created, location: @user_group_contrib }
      else
        format.html { render action: "new" }
        format.json { render json: @user_group_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_group_contribs/1
  # PUT /user_group_contribs/1.json
  def update
    @user_group_contrib = UserGroupContrib.find(params[:id])

    respond_to do |format|
      if @user_group_contrib.update_attributes(params[:user_group_contrib])
        format.html { redirect_to @user_group_contrib, notice: 'User group contrib was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_group_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_group_notes
    @all_user_group_contribs_approved = UserGroupContrib.all_approved
    @all_user_group_contribs = UserGroupContrib.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_group_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Contribution ID", "Group ID", "Note", "Citation", "Created By", "Created At", "Is Approved?", "Approved By ID", "Approved On"]
        @all_user_group_contribs.each do |user_group_contrib|
          csv << [user_group_contrib.id, user_group_contrib.group_id,
          user_group_contrib.annotation, user_group_contrib.bibliography, user_group_contrib.created_by, user_group_contrib.created_at,
          user_group_contrib.is_approved, user_group_contrib.approved_by, user_group_contrib.approved_on]
        end
      end
    else
      user_group_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Contribution ID", "Group ID", "Note", "Citation", "Created By", "Created At"]
        @all_user_group_contribs_approved.each do |user_group_contrib|
          csv << [user_group_contrib.id, user_group_contrib.group_id,
          user_group_contrib.annotation, user_group_contrib.bibliography, user_group_contrib.created_by, user_group_contrib.created_at]
        end
      end
    end
    send_data(user_group_contribs_csv, :type => 'text/csv', :filename => 'SDFB_GroupNotes.csv')
  end

  # DELETE /user_group_contribs/1
  # DELETE /user_group_contribs/1.json
  def destroy
    @user_group_contrib = UserGroupContrib.find(params[:id])
    @user_group_contrib.destroy

    respond_to do |format|
      format.html { redirect_to user_group_contribs_url }
      format.json { head :no_content }
    end
  end
end
