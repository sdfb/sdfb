class UserPersonContribsController < ApplicationController
  # GET /user_person_contribs
  # GET /user_person_contribs.json

  # before_filter :check_login
  before_filter :check_login, :only => [:index, :new, :edit]
  authorize_resource

  def index
    @user_person_contribs = UserPersonContrib.all_approved.paginate(:page => params[:user_person_contribs_page]).per_page(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_person_contribs }
    end
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

  # DELETE /user_person_contribs/1
  # DELETE /user_person_contribs/1.json
  def destroy
    @user_person_contrib = UserPersonContrib.find(params[:id])
    @user_person_contrib.destroy

    respond_to do |format|
      format.html { redirect_to user_person_contribs_url }
      format.json { head :no_content }
    end
  end
end
