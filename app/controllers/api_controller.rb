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
    ids = params[:ids].split(",")
    begin
      @groups = Group.find(ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid group ID(s)"}
    end
    respond_to do |format|
      format.json
      format.html { render :json}
    end
  end

  def network
    begin
      @display_id = params[:ids]
      ids = params[:ids].split(",")
      @people = Person.find(ids)

      @relationships = @people.map(&:relationships).reduce(:+)
      first_degree_ids = @relationships.collect{|r| [r.person1_index, r.person2_index]}.flatten.uniq - @people.collect(&:id)
      @sources = Person.find(first_degree_ids)

    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end
end
