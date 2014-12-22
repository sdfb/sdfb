class RelCatAssignsController < ApplicationController
  # GET /rel_cat_assigns
  # GET /rel_cat_assigns.json
  def index
    @rel_cat_assigns = RelCatAssign.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rel_cat_assigns }
    end
  end

  # GET /rel_cat_assigns/1
  # GET /rel_cat_assigns/1.json
  def show
    @rel_cat_assign = RelCatAssign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rel_cat_assign }
    end
  end

  # GET /rel_cat_assigns/new
  # GET /rel_cat_assigns/new.json
  def new
    @rel_cat_assign = RelCatAssign.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rel_cat_assign }
    end
  end

  # GET /rel_cat_assigns/1/edit
  def edit
    @rel_cat_assign = RelCatAssign.find(params[:id])
  end

  # POST /rel_cat_assigns
  # POST /rel_cat_assigns.json
  def create
    @rel_cat_assign = RelCatAssign.new(params[:rel_cat_assign])

    respond_to do |format|
      if @rel_cat_assign.save
        format.html { redirect_to @rel_cat_assign, notice: 'Rel cat assign was successfully created.' }
        format.json { render json: @rel_cat_assign, status: :created, location: @rel_cat_assign }
      else
        format.html { render action: "new" }
        format.json { render json: @rel_cat_assign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rel_cat_assigns/1
  # PUT /rel_cat_assigns/1.json
  def update
    @rel_cat_assign = RelCatAssign.find(params[:id])

    respond_to do |format|
      if @rel_cat_assign.update_attributes(params[:rel_cat_assign])
        format.html { redirect_to @rel_cat_assign, notice: 'Rel cat assign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rel_cat_assign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rel_cat_assigns/1
  # DELETE /rel_cat_assigns/1.json
  # def destroy
  #   @rel_cat_assign = RelCatAssign.find(params[:id])
  #   @rel_cat_assign.destroy

  #   respond_to do |format|
  #     format.html { redirect_to rel_cat_assigns_url }
  #     format.json { head :no_content }
  #   end
  # end
end
