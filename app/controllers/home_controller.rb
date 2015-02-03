class HomeController < ApplicationController
  def index
    #If there are no relationships, only return the person node
    @people = Person.find_first_degree_for(params[:id])
    if (! @people.empty?) 
    	gon.people = @people 
    else
      if (params[:id].blank?)
        gon.people = Person.find(10000473)
      else
        gon.people = Person.find(params[:id])
      end
    end
    # gon.people = Person.find(10000473)
  	gon.people_list = Person.all_approved.select("id, first_name, last_name, ext_birth_year, prefix, suffix, title")
  	gon.group_data = Group.all_approved.select("id, name, description, person_list")
  end
  def test
  	#gon.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
