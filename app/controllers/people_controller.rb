class PeopleController < ApplicationController
  # GET /people
  # GET /people.json

  # before_filter :check_login
  # before_filter :check_login
  # authorize_resource
  # require 'will_paginate'
  # require 'will_paginate/array'
  load_and_authorize_resource
  
  def index
    # gon.people = Person.all_approved
    # @people_approved = Person.all_approved.paginate(:page => params[:people_approved_page]).per_page(20)
    @people_approved = Person.all_approved.paginate(:page => params[:people_approved_page]).per_page(20)
    gon.people = Person.all_approved
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @people }
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
    @approved_relationships = Relationship.all_for_person(params[:id]).all_approved.paginate(:page => params[:approved_relationships_page]).per_page(20)
    @user_person_contribs = UserPersonContrib.all_for_person(params[:id]).all_approved.paginate(:page => params[:user_person_contribs_page]).per_page(20)
    @groups = GroupAssignment.all_for_person(params[:id]).all_approved.paginate(:page => params[:groups_page]).per_page(20)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    #authorize! :edit, @person
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  # def destroy
  #   @person = Person.find(params[:id])
  #   @person.destroy

  #   respond_to do |format|
  #     format.html { redirect_to people_url }
  #     format.json { head :no_content }
  #   end
  # end

  def search 
    # allows for the admin to search from their dashboard
    @query = params[:query]
    if @query != ""
      @all_results = Person.search(@query)
      @all_results = @all_results.paginate(:page => params[:all_results_page], :per_page => 20)
    end
  end
end
