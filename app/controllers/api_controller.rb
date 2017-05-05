class ApiController < ApplicationController
  def people
    ids = params[:ids].split(",")
    begin
      @people = Person.find(ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid person ID(s)"}
    end
    respond_to do |format|
      format.json
      format.html { render :json}
    end
  end

  def groups
  end

  def person_network
    begin
      id = params[:id]
      @person = Person.find(id)
      @relationships = Person.find_first_degree_for_person(id)
    rescue ActiveRecord::RecordNotFound => e
      @errors << {title: "invalid ID"}
    end
  end

  def shared_network
  end
end
