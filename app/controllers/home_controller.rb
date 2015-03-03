class HomeController < ApplicationController
  autocomplete :group, :name, full: true, :display_value => :name
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  layout "layouts/index_layout"
  def index
    #check if searching for 1 node (id2 is nil)
    if (params[:id2].nil?)
      #If there are no relationships, only return the person node
      # @people = Person.find_first_degree_for(params[:id])
      @data = {}
      
      if (params[:id].nil?)
        @data['people'] = Person.find_2_degrees_for_person(10000473)
      else
        @data['people'] = Person.find_2_degrees_for_person(params[:id])
        if (@data['people'].empty?)
          @data['people'][0] = Person.find(params[:id])
        end
      end
    else
      #The field will return the shared network
      ########needs work
      @data['people'] = Person.find_2_degrees_for_shared_network(params[:id], params[:id2])
    end
    
    # DELETE: This group_data is specifically for creating the group autocomplete and it can be removed
    @data['group_data'] = Group.all_approved.select("id, name, description, person_list")

    #Check if a group search or shared group search is happening
    if (! params[:group].nil?)
      # Check if there is a second group to determine if there is a shared group
      if (params[:group2].nil?)
        #if just a group search (not a shared group search)
        # This field will return the group record that has been searched so that the group info is available
        @data['group'] = Group.find(params[:group]).select("id, name, description, person_list")
        ########needs work
        @data['group_members'] = Group.find_approved_group_members(params[:group])
      else
        # if a shared group search
        # This field will return the group record for Group 1 that has been searched so that the group info is available
        @data['group'] = Group.find(params[:group]).select("id, name, description, person_list")
        # This field will return the group record for Group 2 that has been searched so that the group info is available
        @data['group2'] = Group.find(params[:group2]).select("id, name, description, person_list")
        ########needs work
        @data['group_members'] = Group.find_approved_shared_group_members(params[:group], params[:group2])
      end 
    end
  end
  def list

  end
  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end
end
