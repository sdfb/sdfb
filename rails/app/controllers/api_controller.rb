class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def write

    person_lookup = {}
    group_lookup = {}
    if nodes = params[:nodes]
      nodes.each do |node|
        placeholder_id = nil
        if node["id"] && node["id"]< 1_000_000 
          placeholder_id = node["id"]
          node.delete("id")
        end
        if node["citation"]
          node["bibliography"] = node["citation"]
          node.delete("citation")
        end
        if node["name"]
          node["display_name"] = node["name"]
          node.delete("name")
        end
        if node["alternates"]
          node["search_names_all"] = node["alternates"]
          node.delete("alternates")
        end
        if node["birthDate"]
          node["ext_birth_year"] = node["birthDate"]
          node.delete("birthDate")
        end
        if node["birthDateType"]
          node["birth_year_type"] = node["birthDateType"]
          node.delete("birthDateType")
        end
        if node["deathDate"]
          node["ext_death_year"] = node["deathDate"]
          node.delete("deathDate")
        end
        if node["deathDateType"]
          node["death_year_type"] = node["deathDateType"]
          node.delete("deathDateType")
        end
        if node["id"]
          Person.find_by(node["id"]).update(node)
          Person.save!
        else
          new_person = Person.create!(node)
          puts new_person.inspect
          person_lookup[placeholder_id] = new_person.id
        end
      end
    end

    if groups = params[:groups]
      groups.each do |group|
        placeholder_id = nil
        if group["id"] && group["id"]< 0 
          placeholder_id = group["id"]
          group.delete("id")
        end
        new_record = {
          name: group["name"],
          start_year: group["startDate"],
          end_year: group["endDate"],
          created_by: group["created_by"],
          start_date_type: group["startDateType"],
          end_date_type: group["endDateType"],
          description: group["description"],
          justification: group["justification"],
          bibliography: group["citation"]
        }

        if group["id"]
          Group.find_by(group["id"]).update(new_record)
          Group.save!
        else
          new_group = Group.create!(new_record)
          puts new_group.inspect
          group_lookup[placeholder_id] = new_group.id
        end
      end
    end

    if links = params[:links]
      links.each do |link|
        source_id = link["source"]["id"].to_i
        target_id  = link["target"]["id"].to_i
        source_id = person_lookup[source_id]  if source_id  < 1_000_000
        target_id  = person_lookup[target_id] if target_id  < 1_000_000
        
        rel = Relationship.where("person1_index = ? AND person2_index = ?", source_id, target_id).first
        rel ||= Relationship.where("person1_index = ? AND person2_index = ?", target_id, source_id).first

        if rel.nil?
          new_record = {
            person1_index: source_id,
            person2_index: target_id,
            created_by: link["created_by"],
            bibliography: link["citation"],
            original_certainty: link["confidence"],
          }
          rel = Relationship.create!(new_record)
        else
          update_dates(rel,link)
        end


        new_rel_asssign = {
          relationship_id: rel.id,
          start_date_type: link["startDateType"],
          end_date_type: link["endDateType"],
          created_by: link["created_by"],
          start_year: link["startDate"],
          end_year: link["endDate"],
          certainty: link["confidence"],
          bibliography: link["citation"],
          relationship_type_id: link["relType"]
        }
        UserRelContrib.create!(new_rel_asssign)
      end
    end

    if group_assignments = params[:group_assignments]
      group_assignments.each do |assignment|
        person_id = assignment["person"]["id"].to_i
        group_id  = assignment["group"]["id"].to_i
        person_id = person_lookup[person_id] if person_id < 1_000_000
        group_id  = group_lookup[group_id]   if group_id  < 0
        current_group = GroupAssignment.where("group_id = ? AND person_id = ?", group_id, person_id).first
        if current_group
          update_dates(current_group,assignment)
        else
          new_record = {
            person_id: person_id,
            group_id: group_id,
            start_year: assignment["startDate"],
            end_year: assignment["endDate"],
            created_by: assignment["created_by"],
            start_date_type: assignment["startDateType"],
            end_date_type: assignment["endDateType"],
            bibliography: assignment["citation"]
          }
          GroupAssignment.create!(new_record)
        end
      end
    end

    render json: {status: "200"}
  end
  # 
  # [people description]
  # 
  # @return [type] [description]
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


  def relationships
    ids = params[:ids].split(",")
    begin
      @relationships = Relationship.includes(:user_rel_contribs).find(ids)
      puts @relationships.inspect
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid relationship ID(s)"}
    end
    respond_to do |format|
      format.json 
      format.html { render :json}
    end
  end

  def typeahead
    type   = params[:type]
    query = params[:q]

    if type.blank? || query.blank?
      raise ActionController::RoutingError.new('Not Found')
    end
    
    lookup = {}
    case type
    when "person"
      people = Person.all_approved.pluck(:search_names_all, :display_name, :id)
      full_name = ""
      people.each do |data|
        keys, display_name, id = data
        name_words = keys.split(", ")
        # name_words << display_name
        name_words.uniq!
        name_words.uniq.each do |typeahead_name|
          typeahead_parts = typeahead_name.downcase.split(/\W+/)
          while typeahead_parts.length != 0
            lookup[typeahead_parts.join(" ")] ||= []
            lookup[typeahead_parts.join(" ")] << {name: display_name, id: id.to_s}

            word = typeahead_parts.shift
            lookup[word] ||= []
            lookup[word] << {name: display_name, id: id.to_s}
          end
        end
      end
    when "group"
      groups = Group.all_approved.pluck(:name, :id)
      groups.each do |data|
        group_name, id = data
        group_name_parts = group_name.downcase.split(/\W+/)
        while group_name_parts.length != 0
          lookup[group_name_parts.join(" ")] ||= []
          lookup[group_name_parts.join(" ")] << {name: group_name, id: id.to_s}

          word = group_name_parts.shift
          lookup[word] ||= []
          lookup[word] << {name: group_name, id: id.to_s}
        end
      end
    end
    results = lookup.find_all{|key,val| key.start_with?(query.downcase)}
    if results
      results = results.reduce([]){|memo,a| memo << a[1]}.flatten.uniq
    end
    @results =  results.sort_by{|r| r[:name]} || []
  end


  def groups
      if params[:ids].blank?
        @groups = Group.all
          .includes(:group_assignments)
          .where('group_assignments.is_approved = ?', true).references(:group_assignments)
        group_list = Group.all
          .includes(:group_assignments, :people)
          .where('group_assignments.is_approved = ?', true)
          .references(:group_assignments)
          .to_a

        @connections = []
        while group_list.length > 0
          group = group_list.pop
          group_list.each do |comparison_group|
            shared_members = group.group_assignments.map(&:person) & comparison_group.group_assignments.map(&:person)
            if shared_members.length > 0
              @connections << {target: comparison_group.id, source: group.id, weight: shared_members.length}
            end
          end
        end


        respond_to do |format|
          format.json { render "all_groups"}
          format.html { render :json}
        end
      else
        begin
          ids = params[:ids].split(",")
          @groups = Group
            .includes(:group_assignments, :people)
            .where('group_assignments.is_approved = ?', true).references(:group_assignments)
            .find(ids)
          @people = @groups.map{|g| g.group_assignments.map(&:person)}.reduce(:+).uniq
        rescue ActiveRecord::RecordNotFound => e
          @errors = []
          @errors << {title: "Invalid group ID(s)"}
        end
        respond_to do |format|
          format.json
          format.html { render :json}
        end
      end
  end


  def network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      @display_id = ids.join(",")

      first_degree_ids = []
      second_degree_ids = []

      @people = Person.all_approved.includes(:groups).find(ids)

      @relationships = @people.map(&:relationships).reduce(:+).uniq
      
      first_degree_ids = @relationships.collect do |r| 
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      @sources = Person.includes(:groups).all_approved.find(first_degree_ids)
      first_degree_relationships = @sources.map(&:relationships).reduce(:+)&.uniq || []
      @relationships = @relationships | first_degree_relationships

      if ids.count == 1
        second_degree_ids = first_degree_relationships.collect do |r| 
          [r.person1_index, r.person2_index]
        end.flatten.uniq - (ids + first_degree_ids)

        second_degree_people = Person.includes(:groups).find(second_degree_ids)
        second_degree_relationships = second_degree_people.map(&:relationships).reduce(:+)&.uniq || []

        @relationships = @relationships | second_degree_relationships
        @sources = @sources | second_degree_people
      end

      all_ids = ids | first_degree_ids | second_degree_ids
      @relationships = @relationships.find_all{ |r| all_ids.include?(r.person1_index) && all_ids.include?(r.person2_index)  }

    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end


  def group_network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      @display_id = ids.join(",")

      @groups = Group.all_approved.find(ids)

      @primary_people = @groups.map(&:approved_people).reduce(:+).uniq
      
      @relationships = @primary_people.map(&:relationships).flatten

      first_degree_ids = @relationships.collect do |r|
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      secondary_people = Person.includes(:groups).all_approved.find(first_degree_ids)

      @people = secondary_people | @primary_people 
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end


  def date_math(current_type, new_type, current_date, new_date)
    output_type = nil
    output_date = nil
    case current_type
    when "AF", "AF/IN"
      if current_date <= new_date
        case new_type
        when "IN", "CA"
          output_type = new_type
          output_date = new_date
        when "AF/IN", "AF"
          output_type = "AF/IN"
          output_date = new_date
        when "BF/IN"
          if current_type == "AF"
            output_type = new_type
            output_date = new_date
          end            
        end
      end
    when "BF", "BF/IN"
      if new_date <= current_date
        case new_type
        when "IN", "CA"
          output_type = new_type
          output_date = new_date
        when "BF", "BF/IN"
          output_type = "BF/IN"
          output_date = new_date
        when "AF/IN"
          if current_type == "BF"
            output_type = new_type
            output_date = new_date
          end  
        end
      end
    when "CA"
      if (new_date - current_date).abs <= 10
        if new_type == "CA"
          new_date = (new_date + current_date)/2 
        end
        output_type = new_type
        output_date = new_date
      end
    when "IN"
      if new_type == "CA" && (new_date - current_date).abs <= 4
        output_type = "CA"
        output_date = (new_date + current_date)/2 
      end
    end
    return [output_type, output_date]
  end

  def update_dates(current_object, new_data)
    current_type = current_object.start_date_type
    new_type = new_data["startDateType"]
    current_date = current_object.start_year
    new_date = current_object["startDate"].to_i
    start_type, start_year = date_math(current_type, new_type, current_date, new_date)
    current_object.start_year = start_year if start_year
    current_object.start_year_type = start_type if start_type

    current_type = current_object.end_date_type
    new_type = new_data["endDateType"]
    current_date = current_object.end_year
    new_date = current_object["endDate"].to_i
    end_type, end_year = date_math(current_type, new_type, current_date, new_date)
    current_object.end_year = end_year if end_year
    current_object.end_year_type = end_type if end_type

    current_object.save!
  end
end