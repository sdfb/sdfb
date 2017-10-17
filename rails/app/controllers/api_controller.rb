class ApiController < ApplicationController
  

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
        name_words = keys.split(",").join(" ")
        name_words = "#{display_name} #{name_words}".downcase.split(/\W+/)
        name_words.uniq.each_with_index do |word,i|
          lookup[word.downcase] ||= []
          lookup[word.downcase] << {name: display_name, id: id.to_s}
        end
      end
    when "group"
      groups = Group.pluck(:name, :id)
      groups.each do |data|
        group_name, id = data
        group_name_parts = group_name.downcase.split(/\W+/)
        while group_name_parts.length
          word = group_name_parts.shift
          lookup[word] ||= []
          lookup[word] << {name: group_name, id: id.to_s}
          break if group_name_parts.empty?
          lookup[group_name_parts.join(" ")] ||= []
          lookup[group_name_parts.join(" ")] << {name: group_name, id: id.to_s}
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
        @groups = Group.all.includes(:group_assignments)
        group_list = Group.all.includes(:group_assignments, :people).to_a

        @connections = []
        while group_list.length > 0
          group = group_list.pop
          group_list.each do |comparison_group|
            shared_members = group.people & comparison_group.people
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
          @groups = Group.find(ids)
          @people = @groups.map(&:people).reduce(:+).uniq
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
