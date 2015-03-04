class HomeController < ApplicationController
  autocomplete :group, :name, full: true, :display_value => :name
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  layout "layouts/index_layout"
  def index
    #If there are no relationships, only return the person node
    # @people = Person.find_first_degree_for(params[:id])
    @data = {}
    #only return people if there is no group search because if there is a group search it will be displayed separately
    if (params[:group].nil?)
      #detect if this is a one degree search or a two degree search
      if (params[:id2].nil?)
        @data['people'] = Person.find_first_degree_for(params[:id])
        if (@data['people'].empty?) 
          if (params[:id].blank?)
            @data['people'] = Person.find(10000473)
          else
            @data['people'] = Person.find(params[:id])
          end
        end
      else
        #The field will return searched node 1, searched node 2, shared nodes, and the first degree relationship of the shared network nodes
        @data['people'] = Person.find_2_degrees_for_shared_network(params[:id], params[:id2], params[:confidence], params[:date])
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
        @data['group'] = Group.find(params[:group]).select("id, name, description, person_list")
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
  def list

  end
  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end
  def test
  	#@data.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
