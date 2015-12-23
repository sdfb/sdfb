class UserRelContribsController < ApplicationController
  # this class is known as "Relationship Type Assignments" to the user

  # GET /user_rel_contribs
  # GET /user_rel_contribs.json
  
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  load_and_authorize_resource

  def index
    @user_rel_contribs = UserRelContrib.all_approved.order_by_sdfb_id.paginate(:page => params[:user_rel_contribs_page]).per_page(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_rel_contribs }
    end
  end

  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end

  # GET /user_rel_contribs/1
  # GET /user_rel_contribs/1.json
  def show
    @user_rel_contrib = UserRelContrib.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_rel_contrib }
    end
  end

  # GET /user_rel_contribs/new
  # GET /user_rel_contribs/new.json
  def new
    @user_rel_contrib = UserRelContrib.new
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved.alphabetical
    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_rel_contrib }
    end
  end

  # GET /user_rel_contribs/1/edit
  def edit
    @user_rel_contrib = UserRelContrib.find(params[:id])
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved.alphabetical
    @is_approved = @user_rel_contrib.is_approved
    #authorize! :edit, @user_rel_contrib
  end

  # POST /user_rel_contribs
  # POST /user_rel_contribs.json
  def create
    @user_rel_contrib = UserRelContrib.new(params[:user_rel_contrib])
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved.alphabetical

    respond_to do |format|
      if @user_rel_contrib.save
        format.html { redirect_to @user_rel_contrib, notice: 'User rel contrib was successfully created.' }
        format.json { render json: @user_rel_contrib, status: :created, location: @user_rel_contrib }
      else
        format.html { render action: "new" }
        format.json { render json: @user_rel_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_rel_contribs/1
  # PUT /user_rel_contribs/1.json
  def update
    @user_rel_contrib = UserRelContrib.find(params[:id])
    @relOptions = Relationship.all_approved
    @relationship_id = params[:relationship_id]
    @relType = RelationshipType.all_approved

    respond_to do |format|
      if @user_rel_contrib.update_attributes(params[:user_rel_contrib])
        format.html { redirect_to @user_rel_contrib, notice: 'User rel contrib was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_rel_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_rel_contribs/1
  # DELETE /user_rel_contribs/1.json
  def destroy
    @user_rel_contrib = UserRelContrib.find(params[:id])
    @user_rel_contrib.destroy

    respond_to do |format|
      format.html { redirect_to user_rel_contribs_url }
      format.json { head :no_content }
    end
  end

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to login_url # halts request cycle
    end
  end

  def export_rel_type_assigns_00000_20000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_00000_20000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_00000_20000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_00000_20000.csv')
  end

  def export_rel_type_assigns_20001_40000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_20001_40000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_20001_40000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_20001_40000.csv')
  end

  def export_rel_type_assigns_40001_60000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_40001_60000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_40001_60000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_40001_60000.csv')
  end


  def export_rel_type_assigns_60001_80000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_60001_80000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_60001_80000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_60001_80000.csv')
  end

  def export_rel_type_assigns_80001_100000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_80001_100000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_80001_100000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_80001_100000.csv')
  end

  def export_rel_type_assigns_100001_120000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_100001_120000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_100001_120000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_100001_120000.csv')
  end

  def export_rel_type_assigns_120001_140000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_120001_140000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_120001_140000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_120001_140000.csv')
  end

  def export_rel_type_assigns_140001_160000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_140001_160000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_140001_160000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_140001_160000.csv')
  end

  def export_rel_type_assigns_160001_180000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_160001_180000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_160001_180000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_160001_180000.csv')
  end

  def export_rel_type_assigns_greater_than_180000
    @all_user_rel_contribs_approved = UserRelContrib.for_rel_type_assigns_greater_than_180000.all_approved
    @all_user_rel_contribs = UserRelContrib.for_rel_type_assigns_greater_than_180000.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_rel_contribs_csv = CSV.generate do |csv|
          csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Date Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year", "Justification", "Citation", "Created By ID", "Created At", "Is approved?", "Approved By ID", "Approved On"]
          @all_user_rel_contribs.each do |user_rel_contrib|
              csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
              RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty, 
              user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
              user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
              user_rel_contrib.end_day, user_rel_contrib.end_year,
              user_rel_contrib.annotation, user_rel_contrib.bibliography, user_rel_contrib.created_by, user_rel_contrib.created_at,
              user_rel_contrib.is_approved, user_rel_contrib.approved_by, user_rel_contrib.approved_on]
          end
      end
    else
      user_rel_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship Type Assignment ID", "SDFB Relationship ID", "Relationship Type", "Confidence", "Start Year Type", "Start Month", "Start Day", "Start Year", "End Date Type", "End Month", "End Day", "End Year"]
        @all_user_rel_contribs_approved.each do |user_rel_contrib|
            csv << [user_rel_contrib.id, user_rel_contrib.relationship_id,
            RelationshipType.find(user_rel_contrib.relationship_type_id).name, user_rel_contrib.certainty,
            user_rel_contrib.start_date_type, user_rel_contrib.start_month, user_rel_contrib.start_day,
            user_rel_contrib.start_year, user_rel_contrib.end_date_type,  user_rel_contrib.end_month,
            user_rel_contrib.end_day, user_rel_contrib.end_year]
        end
      end
    end
    send_data(user_rel_contribs_csv, :type => 'text/csv', :filename => 'SDFB_RelTypeAssignments_greater_than_180000.csv')
  end
end
