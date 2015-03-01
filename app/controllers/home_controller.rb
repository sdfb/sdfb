class HomeController < ApplicationController
  autocomplete :group, :name, full: true, :display_value => :name
  autocomplete :person, :search_names_all, full: true, :extra_data => [:display_name, :ext_birth_year], :display_value => :autocomplete_name
  layout "layouts/index_layout"
  def index
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
    #@data['all_people'] = Person.all_approved.select("id, first_name, last_name, ext_birth_year, prefix, suffix, title")
    @data['group_data'] = Group.all_approved.select("id, name, description, person_list")
  end
  def list

  end
  def get_autocomplete_items(parameters)
    active_record_get_autocomplete_items(parameters).where("approved_by is not null and is_active is true and is_rejected is false")
  end
end
