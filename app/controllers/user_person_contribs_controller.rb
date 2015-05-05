class UserPersonContribsController < ApplicationController
  # GET /user_person_contribs
  # GET /user_person_contribs.json

  # before_filter :check_login
  # before_filter :check_login, :only => [:index, :new, :edit]
  # authorize_resource
  
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  load_and_authorize_resource

  def index
    @user_person_contribs = UserPersonContrib.all_approved.order_by_sdfb_id.paginate(:page => params[:user_person_contribs_page]).per_page(30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_person_contribs }
    end
  end

  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end

  # GET /user_person_contribs/1
  # GET /user_person_contribs/1.json
  def show
    @user_person_contrib = UserPersonContrib.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_person_contrib }
    end
  end

  # GET /user_person_contribs/new
  # GET /user_person_contribs/new.json
  def new
    @user_person_contrib = UserPersonContrib.new
    @personOptions = Person.all_approved
    @person_id = params[:person_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_person_contrib }
    end
  end

  # GET /user_person_contribs/1/edit
  def edit
    @user_person_contrib = UserPersonContrib.find(params[:id])
    @personOptions = Person.all_approved
    @is_approved = @user_person_contrib.is_approved
    # authorize! :edit, @user_person_contrib
  end

  # POST /user_person_contribs
  # POST /user_person_contribs.json
  def create
    @user_person_contrib = UserPersonContrib.new(params[:user_person_contrib])
    @personOptions = Person.all_approved

    respond_to do |format|
      if @user_person_contrib.save
        format.html { redirect_to @user_person_contrib, notice: 'User person contrib was successfully created.' }
        format.json { render json: @user_person_contrib, status: :created, location: @user_person_contrib }
      else
        format.html { render action: "new" }
        format.json { render json: @user_person_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_person_contribs/1
  # PUT /user_person_contribs/1.json
  def update
    @user_person_contrib = UserPersonContrib.find(params[:id])

    respond_to do |format|
      if @user_person_contrib.update_attributes(params[:user_person_contrib])
        format.html { redirect_to @user_person_contrib, notice: 'User person contrib was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_person_contrib.errors, status: :unprocessable_entity }
      end
    end
  end

  def export_people_notes
    @all_user_person_contribs_approved = UserPersonContrib.all_approved
    @all_user_person_contribs = UserPersonContrib.all_active_unrejected
    if (current_user.user_type == "Admin")
      user_person_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Contribution ID", "Person ID", "Annotation", "Bibliography", "Created By", "Created At", "Is approved?", "Approved By ID", "Approved On"]
        @all_user_person_contribs.each do |user_person_contrib|
          csv << [user_person_contrib.id, user_person_contrib.person_id,
          user_person_contrib.annotation, user_person_contrib.bibliography, user_person_contrib.created_by, user_person_contrib.created_at,
          user_person_contrib.is_approved, user_person_contrib.approved_by, user_person_contrib.approved_on]
        end
      end
    else
      user_person_contribs_csv = CSV.generate do |csv|
        csv << ["SDFB Contribution ID", "Person ID", "Annotation", "Bibliography", "Created By", "Created At"]
        @all_user_person_contribs_approved.each do |user_person_contrib|
          csv << [user_person_contrib.id, user_person_contrib.person_id,
          user_person_contrib.annotation, user_person_contrib.bibliography, user_person_contrib.created_by, user_person_contrib.created_at]
        end
      end
    end
    send_data(user_person_contribs_csv, :type => 'text/csv', :filename => 'SDFB_PersonNotes.csv')
  end

  # DELETE /user_person_contribs/1
  # DELETE /user_person_contribs/1.json
  # def destroy
  #   @user_person_contrib = UserPersonContrib.find(params[:id])
  #   @user_person_contrib.destroy

  #   respond_to do |format|
  #     format.html { redirect_to user_person_contribs_url }
  #     format.json { head :no_content }
  #   end
  # end
end
