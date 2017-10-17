class ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def write

    id_lookup = {}
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
          new_person.delete
        end
      end
    end

    if groups = params[:groups]

    end

    if links = params[:links]

    end

    if group_assignments = params[:group_assignments]

    end


    render json: {ok: true}, status: :accepted
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
      people = Person.pluck(:search_names_all, :display_name, :id)
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
      groups = Group.pluck(:name, :id)
      groups.each do |data|
        group_name, id = data
        group_name_parts = group_name.downcase.split(/\W+/)
        while group_name_parts.length
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
      first_degree_ids = []
      second_degree_ids = []
      @display_id = ids.join(",")

      @people = Person.includes(:groups).find(ids)

      @relationships = @people.map(&:relationships).reduce(:+).uniq
      
      first_degree_ids = @relationships.collect do |r| 
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      @sources = Person.includes(:groups).find(first_degree_ids)
      first_degree_relationships = @sources.map(&:relationships).reduce(:+).uniq
      @relationships = @relationships | first_degree_relationships

      if ids.count == 1
        second_degree_ids = first_degree_relationships.collect do |r| 
          [r.person1_index, r.person2_index]
        end.flatten.uniq - (ids + first_degree_ids)
        second_degree_people = Person.includes(:groups).find(second_degree_ids)
        second_degree_relationships = second_degree_people.map(&:relationships).reduce(:+).uniq
        @relationships = @relationships | second_degree_relationships
        @sources = @sources | second_degree_people
      end

      all_ids = ids | first_degree_ids | second_degree_ids
      @relationships = @relationships.find_all{ |r| all_ids.include?(r.person1_index) && all_ids.include?(r.person2_index)   }

    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end


  def group_network
    begin
      ids = params[:ids].split(",").map(&:to_i).uniq.sort
      @display_id = ids.join(",")

      @groups = Group.find(ids)

      @primary_people = @groups.map(&:people).reduce(:+).uniq
      # @member_ids = @people.map(&:id).flatten.uniq - ids

      @relationships = @primary_people.map(&:relationships).flatten
      first_degree_ids = @relationships.collect do |r|
        [r.person1_index, r.person2_index]
      end.flatten.uniq - ids

      @people = @primary_people | Person.includes(:groups).find(first_degree_ids)
    rescue ActiveRecord::RecordNotFound => e
      @errors = []
      @errors << {title: "invalid person ID(s)"}
    end
  end

end
