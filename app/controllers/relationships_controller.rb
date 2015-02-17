class RelationshipsController < ApplicationController
  # GET /relationships
  # GET /relationships.json
  
  #before_filter :check_login
  # before_filter :check_login, :only => [:index, :new, :edit]
  # authorize_resource

  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  load_and_authorize_resource

  helper PeopleHelper

  def index
    #@relationships_approved = Relationship.all_approved.paginate(:page => params[:relationships_approved_page]).per_page(20)
    @approved_relationships = Relationship.all_approved.paginate(:page => params[:approved_relationships_page]).per_page(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @relationships }
    end
  end

  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end

  # GET /relationships/1
  # GET /relationships/1.json
  def show
    @relationship = Relationship.find(params[:id])
    @user_rel_contribs = UserRelContrib.all_approved.all_for_relationship(params[:id]).paginate(:page => params[:user_rel_contribs_page]).per_page(20)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @relationship }
    end
  end

  # GET /relationships/new
  # GET /relationships/new.json
  def new
    @person1_id = params[:person1_id]
    @relationship = Relationship.new
    @personOptions = Person.all_approved.alphabetical

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @relationship }
    end
  end

  # GET /relationships/1/edit
  def edit
    @relationship = Relationship.find(params[:id])
    @personOptions = Person.all_approved.alphabetical
    @is_approved = @relationship.is_approved
    #authorize! :edit, @relationship
  end

  def export_rels
  end

  # POST /relationships
  # POST /relationships.json
  def create
    @relationship = Relationship.new(params[:relationship])
    @personOptions = Person.all_approved.alphabetical

    respond_to do |format|
      if @relationship.save
        format.html { redirect_to @relationship, notice: 'Relationship was successfully created.' }
        format.json { render json: @relationship, status: :created, location: @relationship }
      else
        format.html { render action: "new" }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /relationships/1
  # PUT /relationships/1.json
  def update
    @relationship = Relationship.find(params[:id])
    @personOptions = Person.all_approved.alphabetical
    
    respond_to do |format|
      if @relationship.update_attributes(params[:relationship])
        format.html { redirect_to @relationship, notice: 'Relationship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    @person1Query = params[:person1Query]
    @person2Query = params[:person2Query]
    if ((@person1Query != "") && (@person2Query != ""))
      if (logged_in? == true)
        if ((current_user.user_type == "Admin") || (current_user.user_type == "Curator"))
          @all_results1 = Relationship.search_all(@person1Query, @person2Query)
        else
          @all_results1 = Relationship.search_approved(@person1Query, @person2Query)
        end
      else
        @all_results1 = Relationship.search_approved(@person1Query, @person2Query)
      end
      @all_results = @all_results1.paginate(:page => params[:all_results_page], :per_page => 20)
    end
  end
  # DELETE /relationships/1
  # DELETE /relationships/1.json
  # def destroy
  #   @relationship = Relationship.find(params[:id])
  #   @relationship.destroy

  #   respond_to do |format|
  #     format.html { redirect_to relationships_url }
  #     format.json { head :no_content }
  #   end
  # end

  def export_rels_for_rels_100000000_100020000
    @all_relationships_approved = Relationship.for_rels_100000000_100020000.all_approved
    @all_relationships = Relationship.for_rels_100000000_100020000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100000000_100020000.csv')
  end

    def export_rels_for_rels_100020001_100040000
    @all_relationships_approved = Relationship.for_rels_100020001_100040000.all_approved
    @all_relationships = Relationship.for_rels_100020001_100040000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100020001_100040000.csv')
  end

    def export_rels_for_rels_100040001_100060000
    @all_relationships_approved = Relationship.for_rels_100040001_100060000.all_approved
    @all_relationships = Relationship.for_rels_100040001_100060000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100040001_100060000.csv')
  end

    def export_rels_for_rels_100060001_100080000
    @all_relationships_approved = Relationship.for_rels_100060001_100080000.all_approved
    @all_relationships = Relationship.for_rels_100060001_100080000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100060001_100080000.csv')
  end

    def export_rels_for_rels_100080001_100100000
    @all_relationships_approved = Relationship.for_rels_100080001_100100000.all_approved
    @all_relationships = Relationship.for_rels_100080001_100100000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100080001_100100000.csv')
  end

    def export_rels_for_rels_100100001_100120000
    @all_relationships_approved = Relationship.for_rels_100100001_100120000.all_approved
    @all_relationships = Relationship.for_rels_100100001_100120000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100100001_100120000.csv')
  end

    def export_rels_for_rels_100120001_100140000
    @all_relationships_approved = Relationship.for_rels_100120001_100140000.all_approved
    @all_relationships = Relationship.for_rels_100120001_100140000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100120001_100140000.csv')
  end

    def export_rels_for_rels_100140001_100160000
    @all_relationships_approved = Relationship.for_rels_100140001_100160000.all_approved
    @all_relationships = Relationship.for_rels_100140001_100160000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100140001_100160000.csv')
  end

    def export_rels_for_rels_100160001_100180000
    @all_relationships_approved = Relationship.for_rels_100000000_100020000.all_approved
    @all_relationships = Relationship.for_rels_100160001_100180000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_100160001_100180000.csv')
  end

    def export_rels_for_rels_greater_than_100180000
    @all_relationships_approved = Relationship.for_rels_greater_than_100180000.all_approved
    @all_relationships = Relationship.for_rels_greater_than_100180000
    if (current_user.user_type == "Admin")
      relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID", "Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name",
          "Original Certainty", "Maximum Certainty", "Start Month", "Start Day", "Start Year",  "End Month",
          "End Day", "End Year", "Edge Birthdate Certainty", "Justification", "Created By ID", "Created By", "Created At", "Is approved?",
          "Approved By ID", "Approved By", "Approved On"]
        @all_relationships.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty, 
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year,
            relationship.edge_birthdate_certainty, relationship.justification,
            relationship.created_by, User.find(relationship.created_by).get_person_name, relationship.created_at,
            relationship.is_approved, relationship.approved_by, User.find(relationship.approved_by).get_person_name, relationship.approved_on]
        end
      end
    else
    relationship_csv = CSV.generate do |csv|
        csv << ["SDFB Relationship ID","Person 1 ID", "Person 1 Name", "Person 2 ID", "Person 2 Name", "Original Certainty", "Maximum Certainty",
          "Start Day", "Start Year",  "End Month", "End Day", "End Year"]
        @all_relationships_approved.each do |relationship|
          csv << [relationship.id, relationship.person1_index, Person.find(relationship.person1_index).display_name, relationship.person2_index,
            Person.find(relationship.person2_index).display_name, relationship.original_certainty, relationship.max_certainty,
            relationship.start_month, relationship.start_day, relationship.start_year, relationship.end_month, relationship.end_day, relationship.end_year]
        end
      end
    end
    send_data(relationship_csv, :type => 'text/csv', :filename => 'SDFB_relationships_greater_than_100180000.csv')
  end
end
