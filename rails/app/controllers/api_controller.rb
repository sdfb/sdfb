class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  include ApiHelper

  #-----------------------------
  def curate
    return head(:forbidden) unless current_user && ["Admin", "Curator"].include?(current_user.user_type)
    offset = params["offset"] || 0
    size = params["size"] || 20
    case params["type"]
    when "people"
      @people = Person.all_unapproved.limit(size).offset(offset)
      render "people"      
    when "groups"
      @groups = Group.all_unapproved.limit(size).offset(offset)
      render "groups"    
    when "group_assignments"
      @assignments = GroupAssignment.all_unapproved.limit(size).offset(offset)
      person_ids = @assignments.collect{|l| l.person_id}.uniq
      group_ids = @assignments.collect{|l| l.group_id}.uniq
      @people = Person.find(person_ids)
      @groups = Group.find(group_ids)
      render "group_assignments"      
    when "relationships"
      @relationships = Relationship.all_unapproved.limit(size).offset(offset)
      person_ids = @relationships.collect{|l| [l.person1_index,l.person2_index]}.flatten.uniq
      @people = Person.find(person_ids)
      render "curation_relationships"
    when "links"
      @links = UserRelContrib.all_unapproved.limit(size).offset(offset)
      person_ids = @links.collect{|l| [l.relationship.person1_index,l.relationship.person2_index]}.flatten.uniq
      @people = Person.find(person_ids)
      render "links"      
    else
      return head(:bad_request)
    end
  end

  #-----------------------------
  def recent_contributions
    size = params["size"] || 5
    person_ids = []
    group_ids = []

    @people = Person.all_approved.limit(size).order(approved_on: :desc)
    
    @groups = Group.all_approved.limit(size).order(approved_on: :desc)

    @relationships = Relationship.all_approved.limit(size).order(approved_on: :desc)
    person_ids += @relationships.collect{|l| [l.person1_index,l.person2_index]}.flatten
    
    @assignments = GroupAssignment.all_approved.limit(size).order(approved_on: :desc)
    person_ids += @assignments.collect{|l| l.person_id}
    group_ids += @assignments.collect{|l| l.group_id}

    @links = UserRelContrib.all_approved.limit(size).order(approved_on: :desc)
    person_ids += @links.collect{|l| [l.relationship.person1_index,l.relationship.person2_index]}.flatten

    @other_people = Person.find(person_ids.uniq)
    @other_groups = Group.find(group_ids.uniq)
  end


  #-----------------------------
  def all_people
    offset = params["offset"] || 0
    size = params["size"] || 20
    @people = Person.all_approved.limit(size).offset(offset).order(:display_name)
    render "people"
  end  

  #-----------------------------
  def all_relationships
    offset = params["offset"] || 0
    size = params["size"] || 20
    @relationships = Relationship.all_approved.limit(size).offset(offset).order(max_certainty: :desc)
    person_ids = @relationships.collect{|l| [l.person1_index,l.person2_index]}.flatten.uniq
    @people = Person.find(person_ids)
    render "curation_relationships"

  end  


  #-----------------------------
  def users
    user_id = params[:id]
    return head(:bad_request) unless user_id

    # you can only get your own ID unless you're an admin
    if current_user && (current_user.user_type == "Admin" || current_user.id = user_id)
      respond_to do |format|
        begin
          user = User.find(user_id)
          format.json { render json: user.as_json}
          format.html { render :json}
        rescue ActiveRecord::RecordNotFound => e
          format.json { render json: {}, status: :unprocessable_entity }
          format.html { render :json}
        end
      end
    else
      respond_to do |format|
        begin
          user = User.find(user_id)
          minimal_user = {id: user.id, username: user.username}
          format.json { render json: minimal_user}
          format.html { render :json}
        rescue ActiveRecord::RecordNotFound => e
          format.json { render json: {}, status: :unprocessable_entity }
          format.html { render :json}
        end
      end
    end
  end

  #-----------------------------
  def edit_user
    return head(:forbidden) unless current_user
    return head(:forbidden) unless params["id"].to_s == current_user.id.to_s || current_user.user_type == "Admin"
    fields = %w{about_description affiliation email first_name last_name username prefix orcid is_public}
    fields += %w{is_active user_type} if current_user.user_type == "Admin"
    fields += %w{password password_confirmation} if params["id"].to_s == current_user.id.to_s
    new_record = fields.collect{|field| [field, params[field]] if params[field]}.compact.to_h
    respond_to do |format|
      begin
        user = User.find(params["id"])
        user.update(new_record)
        user.save!
        format.json { render json: user.as_json}
        format.html { render :json}
      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
        errors = e.record ?  e.record.errors : {}
        format.json { render json: errors, status: :unprocessable_entity }
        format.html { render :json}
      end

    end
  end

  #-----------------------------
  def new_user
    return head(:forbidden) if current_user
    return head(:bad_request) if params["id"]
    fields = %w{about_description affiliation email first_name last_name username prefix orcid is_public password password_confirmation}
    new_record = fields.collect{|field| [field, params[field]] if params[field]}.compact.to_h
    respond_to do |format|
      begin
        user = User.create!(new_record)
        format.json { render json: user.as_json}
        format.html { render :json}
      rescue ActiveRecord::RecordInvalid => e
        format.json { render json: e.record.errors, status: :unprocessable_entity }
        format.html { render :json}
      end
    end
  end

  #-----------------------------
  def write
    return head(:forbidden) unless current_user
    person_lookup = {}
    group_lookup = {}
    if nodes = params[:nodes]
      nodes.each do |node|
        placeholder_id = nil
        if node["id"] && node["id"].to_i < 1_000_000 
          placeholder_id = node["id"]
          node.delete("id")
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
          node["birth_year"] = node["birthDate"]
          node.delete("birthDate")
        end
        if node["birthDateType"]
          node["birth_year_type"] = node["birthDateType"]
          node.delete("birthDateType")
        end
        if node["deathDate"]
          node["death_year"] = node["deathDate"]
          node.delete("deathDate")
        end
        if node["deathDateType"]
          node["death_year_type"] = node["deathDateType"]
          node.delete("deathDateType")
        end
        if ["Admin", "Curator"].include?(current_user.user_type)
          if node.keys.include?("is_approved")
            node["approved_by"] = current_user.id if node["is_approved"]
          end
        else
          node.delete("is_approved")
          node.delete("is_active")
        end
        node.delete("created_by")



        if node["id"]
          person = Person.find(node["id"].to_i)
          node.delete("id")
          if node.keys.count == 1 && node.keys.first == "is_active"
            person.update_column(:is_active, node["is_active"])
          else
            person.update!(node)
          end
        else
          node["created_by"] = current_user.id
          new_person = Person.create!(node)
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
          start_date_type: group["startDateType"],
          end_date_type: group["endDateType"],
          description: group["description"],
          justification: group["justification"],
          citation: group["citation"]
        }
        if ["Admin", "Curator"].include?(current_user.user_type)
          if group.keys.include?("is_approved")
            new_record[:is_approved] = group["is_approved"]
            new_record[:approved_by] = current_user.id if group["is_approved"]
          end
          new_record[:is_active]   = group["is_active"] unless group["is_active"].nil?
        end
    
        if group["id"]
          new_record.reject! {|_,v| v.nil?}
          Group.find(group["id"]).update!(new_record)
        else
        new_record[:created_by] = current_user.id
          new_group = Group.create!(new_record)
          group_lookup[placeholder_id] = new_group.id
        end
      end
    end

    if links = params[:links]
      links.each do |link|

        if link["id"] 
          rel = Relationship.find(link["id"])
          puts rel
        else
          begin        
            source_id = link["source"]["id"].to_i 
            source_id = person_lookup[source_id]  if source_id  < 1_000_000
          rescue Exception => e
            source_id = nil
          end
          begin
            target_id  = link["target"]["id"].to_i
            target_id  = person_lookup[target_id] if target_id  < 1_000_000          
          rescue Exception => e
            target_id = nil
          end
          
          if source_id && target_id
            rel = Relationship.where("person1_index = ? AND person2_index = ?", source_id, target_id).first
            rel ||= Relationship.where("person1_index = ? AND person2_index = ?", target_id, source_id).first
          else
            rel = nil
          end
        end

        if rel.nil?
          new_record = {
            person1_index: source_id,
            person2_index: target_id,
            created_by: current_user.id,
            citation: link["citation"],
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
          created_by: current_user.id,
          start_year: link["startDate"],
          end_year: link["endDate"],
          certainty: link["confidence"],
          citation: link["citation"],
          relationship_type_id: link["relType"]
        }
        UserRelContrib.create!(new_rel_asssign)
      end
    end

    if group_assignments = params[:group_assignments]
      group_assignments.each do |assignment|
      
        person_id = assignment.dig("person","id")
        group_id  = assignment.dig("group","id")
        person_id = person_lookup[person_id] if person_id && person_id.to_i < 1_000_000
        group_id  = group_lookup[group_id]   if group_id && group_id.to_i  < 0
       
        update_dates(Group.find(group_id),assignment) if group_id

        new_record = {
          person_id: person_id,
          group_id: group_id,
          start_year: assignment["startDate"],
          end_year: assignment["endDate"],
          start_date_type: assignment["startDateType"],
          end_date_type: assignment["endDateType"],
          citation: assignment["citation"]
        }
        if ["Admin", "Curator"].include?(current_user.user_type)
          if assignment.keys.include?("is_approved")
            new_record[:is_approved] = assignment["is_approved"]
            new_record[:approved_by] = current_user.id if assignment["is_approved"]
          end
          new_record["is_active"] = assignment["is_active"]   unless assignment["is_active"].nil?
        end
        if assignment["id"]
          new_record.reject! {|_,v| v.nil?}
          GroupAssignment.find(assignment["id"]).update!(new_record)
        else
          new_record[:created_by] = current_user.id
          GroupAssignment.create!(new_record)
        end
      end
    end

    if relationships = params[:relationships] 
      relationships.each do |relationship|
        new_record = {
          original_certainty: relationship["confidence"],
          person1_index: relationship.dig("source","id"),
          person2_index: relationship.dig("target","id"),
          start_date_type: relationship["startDateType"],
          start_year: relationship["startDate"],
          end_date_type: relationship["endDateType"],
          end_year: relationship["endDate"],
          justification: relationship["justification"],
          citation: relationship["citation"]
        }
        if ["Admin", "Curator"].include?(current_user.user_type)
          if relationship.keys.include?("is_approved")
            new_record[:is_approved] = relationship["is_approved"]
            new_record[:approved_by] = current_user.id if relationship["is_approved"]
          end
          new_record[:is_active]   = relationship["is_active"] unless relationship["is_active"].nil?
        end
      
        if relationship["id"]
          new_record.reject! {|_,v| v.nil?}
          Relationship.find(relationship["id"]).update!(new_record)
        else
        new_record[:created_by] = current_user.id
          Relationship.create!(new_record)
        end
      end
    end

    if relationship_assignments = params[:relationshipAssignments] 
      relationship_assignments.each do |link|
        new_record = {
          relationship_id: link["relationshipId"],
          start_date_type: link["startDateType"],
          end_date_type: link["endDateType"],
          start_year: link["startDate"],
          end_year: link["endDate"],
          certainty: link["confidence"],
          citation: link["citation"],
          relationship_type_id: link["relType"]
        }
        if ["Admin", "Curator"].include?(current_user.user_type)
          if link.keys.include?("is_approved")
            new_record[:is_approved] = link["is_approved"]
            new_record[:approved_by] = current_user.id if link["is_approved"]
          end
          new_record[:is_active]   = link["is_active"] unless link["is_active"].nil?
        end
      
        if link["id"]
          new_record.reject! {|_,v| v.nil?}
          UserRelContrib.find(link["id"]).update!(new_record)
        else
        new_record[:created_by] = current_user.id
          UserRelContrib.create!(new_record)
        end
      end
    end

    render json: {status: "200"}
  end
  # 
  # [people description]
  # 
  # @return [type] [description]
  #-----------------------------
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


  #-----------------------------
  def relationships
    ids = params[:ids].split(",")
    begin
      @relationships = Relationship.includes(:user_rel_contribs).find(ids)

      first_degree_ids = @relationships.collect do |r| 
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids
      @people = Person.includes(:groups).all_approved.find(first_degree_ids)

    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "Invalid relationship ID(s)"}
    end
    respond_to do |format|
      format.json 
      format.html { render :json}
    end
  end

  #-----------------------------
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
        name_words << display_name
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


  #-----------------------------
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


  #-----------------------------
  def network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      max_certainty = params[:certainty].to_i || SDFB::DEFAULT_CONFIDENCE
      @display_id = ids.join(",")

      first_degree_ids = []
      second_degree_ids = []

      @people = Person.includes(groups: :group_assignments).all_approved.find(ids)

      @relationships = @people.map{|p| p.relationships(max_certainty)}.reduce(:+).uniq
      
      first_degree_ids = @relationships.collect do |r| 
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids


      @sources = Person.includes(groups: :group_assignments).all_approved.find(first_degree_ids)
      first_degree_relationships = @sources.map{|p| p.relationships(max_certainty)}.reduce(:+)&.uniq || []
      @relationships = @relationships | first_degree_relationships

      if ids.count == 1
        second_degree_ids = first_degree_relationships.collect do |r| 
          [r.person1_index, r.person2_index]
        end.flatten.uniq - (ids + first_degree_ids)

        second_degree_people = Person.includes(groups: :group_assignments).all_approved.find(second_degree_ids)
        second_degree_relationships = second_degree_people.map{|p| p.relationships(max_certainty)}.reduce(:+)&.uniq || []

        @relationships = @relationships | second_degree_relationships
        @sources = @sources | second_degree_people
      end

      all_ids = ids | first_degree_ids | second_degree_ids
      @relationships = @relationships.find_all{ |r| all_ids.include?(r.person1_index) && all_ids.include?(r.person2_index)  }
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
    render json: network_to_json
  end


  #-----------------------------
  def group_network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      max_certainty = params[:certainty].to_i || SDFB::DEFAULT_CONFIDENCE
      @display_id = ids.join(",")

      @groups = Group.all_approved.find(ids)

      @primary_people = @groups.map(&:approved_people).reduce(:+).uniq
      
      @relationships = @primary_people.map{|p| p.relationships(max_certainty)}.flatten

      first_degree_ids = @relationships.collect do |r|
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      secondary_people = Person.includes(:groups).all_approved.find(first_degree_ids)

      @people = secondary_people | @primary_people 
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid group ID(s)"}
    end
  end


  #-----------------------------
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


  #-----------------------------
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