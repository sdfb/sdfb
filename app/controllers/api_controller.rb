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
      left_side = Relationship.where(person1_index: id, max_certainty: (SDFB::DEFAULT_CONFIDENCE..100))
      right_side = Relationship.where(person2_index: id, max_certainty: (SDFB::DEFAULT_CONFIDENCE..100))
      @relationships = left_side + right_side
    rescue ActiveRecord::RecordNotFound => e
      @errors << {title: "invalid ID"}
    end
  end
end
