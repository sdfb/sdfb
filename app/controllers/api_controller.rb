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
      @display_id = id
      @person = Person.find(id)
      @people = [@person]
      left_side = Relationship.where(person1_index: id, max_certainty: (SDFB::DEFAULT_CONFIDENCE..100))
      right_side = Relationship.where(person2_index: id, max_certainty: (SDFB::DEFAULT_CONFIDENCE..100))
      @relationships = left_side + right_side
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid ID"}
    end
  end

  def shared_network
    begin
      ids = params[:ids].split(",")
      @people = Person.find(ids)

      left_side = Relationship.where(person1_index: @people.first.id, max_certainty: (SDFB::DEFAULT_CONFIDENCE..100))
      right_side = Relationship.where(person2_index: @people.second.id, max_certainty: (SDFB::DEFAULT_CONFIDENCE..100))
      @relationships = left_side & right_side
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid ID"}
    end
  end
end
