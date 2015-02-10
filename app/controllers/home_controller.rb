class HomeController < ApplicationController
  autocomplete :person, :search_names_all, full: true, :extra_data => [:first_name, :last_name, :ext_birth_year], :display_value => :autocomplete_name
  def index
    #If there are no relationships, only return the person node
    # @people = Person.find_first_degree_for(params[:id])
    @data = {}
    @data['people'] = Person.find_first_degree_for(params[:id])

    if (@data['people'].empty?) 
      if (params[:id].blank?)
        @data['people'] = Person.find(10000473)
      else
        @data['people'] = Person.find(params[:id])
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

  def test
  	#@data.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
