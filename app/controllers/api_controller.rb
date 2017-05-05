class ApiController < ApplicationController
  def people
    ids = params[:ids].split(",")
    @errors = []
    begin
      @people = Person.find(ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors << {title: "Invalid person ID(s)"}
    end
    respond_to do |format|
      format.json
      format.html { render :json}
    end
  end

  def groups
  end
end
