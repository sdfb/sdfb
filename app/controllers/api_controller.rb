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

  def typeahead
    type   = params[:type]
    query = params[:q]

    raise Error if type.blank? || query.blank?

    case type
    when "person"

      lookup = {}
      people = Person.pluck(:search_names_all, :display_name, :id)
      people.each do |data|
        keys, name, id = data
        keys.split(/\W+/).uniq!.each do |word|
          lookup[word.downcase] ||= []
          lookup[word.downcase] << {name: name, id: id}
        end
      end

      results = lookup.find_all{|key,val| key.start_with?(query.downcase)}
      if results
        results = results.reduce([]){|memo,a| memo << a[1]}.flatten.uniq
      end
      @results =  results || {}

    when "group"
    else  
      # error goes here
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
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      @display_id = ids.join(",")

      @people = Person.find(ids)

      @relationships = @people.map(&:relationships).reduce(:+).uniq
      
      first_degree_ids = @relationships.collect do |r| 
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      @sources = Person.find(first_degree_ids)

      if ids.count == 1
        second_degree_relationships = @sources.map(&:relationships).reduce(:+).uniq
        second_degree_ids = second_degree_relationships.collect do |r| 
          [r.person1_index, r.person2_index]
        end.flatten.uniq - (ids + first_degree_ids)
        second_degree_people = Person.find(second_degree_ids)

        @relationships = @relationships | second_degree_relationships
        @sources = @sources | second_degree_people
      end

    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end
end
