class HomeController < ApplicationController
  autocomplete :group, :name, full: true, :display_value => :name
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  layout "layouts/index_layout"
  def index
    #If there are no relationships, only return the person node
    # @people = Person.find_first_degree_for(params[:id])
    @data = {}
    #only return people if there is no group search because if there is a group search it will be displayed separately
    if (params[:id].nil? && params[:group].nil?)
      #detect if this is a one degree search or a two degree search
      if (params[:id2].nil?)
        @data['people'] = Person.find_two_degree_for_person(params[:id], params[:confidence], params[:date])
      else
        #The field will return searched node 1, searched node 2, shared nodes, and the first degree relationship of the shared network nodes
        @data['people'] = Person.find_two_degree_for_network(params[:id], params[:id2], params[:confidence], params[:date])
      end
    end
    #@data['all_people'] = Person.all_approved.select("id, first_name, last_name, ext_birth_year, prefix, suffix, title")
    
    # DELETE: This group_data is specifically for creating the group autocomplete and it can be removed
    @data['group_data'] = Group.all_approved.select("id, name, description, person_list")

    #Check if a group search or shared group search is happening
    if (! params[:group].nil?)
      # Check if there is a second group to determine if there is a shared group
      if (params[:group2].nil?)
        #if just a group search (not a shared group search)
        # This field will return the group record that has been searched so that the group info is available
        @data['group'] = Group.select("id, name, description, person_list").find(params[:group])
        # Returns the people who are in the group
        @data['group_members'] = Person.all_members_of_a_group(params[:group]).all_approved
      else
        # if a shared group search
        # This field will return the group record for Group 1 that has been searched so that the group info is available
        @data['group'] = Group.find(params[:group]).select("id, name, description, person_list")
        # This field will return the group record for Group 2 that has been searched so that the group info is available
        @data['group2'] = Group.find(params[:group2]).select("id, name, description, person_list")
        # Returns the people who are in both searched groups
        @data['group_members'] = Person.all_members_of_2_groups(params[:group], params[:group2])
      end 
    end
  end

  def update_node_info
    @node_id = params[:node_id]
    @node_info = Person.select("display_name, first_name, last_name, ext_birth_year, ext_death_year, birth_year_type, death_year_type, group_list, historical_significance, odnb_id, prefix, suffix, title").where("id = ?", @node_id)
    @node_info_display_name = @node_info[0][:display_name]
    @node_info_first_name = @node_info[0][:first_name]
    @node_info_last_name = @node_info[0][:last_name]
    @node_info_birth = @node_info[0][:ext_birth_year]
    @node_info_birth_year_type = @node_info[0][:birth_year_type]
    @node_info_death = @node_info[0][:ext_death_year]
    @node_info_death_year_type = @node_info[0][:death_year_type]
    @node_info_group_list = @node_info[0][:group_list]
    @node_info_historical_significance = @node_info[0][:historical_significance]
    @node_info_odnb_id = @node_info[0][:odnb_id]
    @node_info_prefix = @node_info[0][:prefix]
    @node_info_suffix = @node_info[0][:suffix]
    @node_info_title = @node_info[0][:title]
    respond_to do |format|
      format.js
    end
  end

  def update_network_info
    @source_id = params[:source_id]
    @target_id = params[:target_id]
    @source_name = Person.select("display_name").where("id = ?", @source_id)[0][:display_name]
    @target_name = Person.select("display_name").where("id = ?", @target_id)[0][:display_name]
    @network_info = Relationship.select("id, max_certainty").where("person1_index = ? AND person2_index = ? OR person1_index = ? AND person2_index = ? ", @source_id, @target_id, @target_id, @source_id)
    @network_info_id = @network_info[0][:id]
    @network_info_confidence = @network_info[0][:max_certainty]
    respond_to do |format|
      format.js
    end
  end
  
  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end
  def test
  	#@data.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
