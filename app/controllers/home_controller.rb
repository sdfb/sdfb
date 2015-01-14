class HomeController < ApplicationController
  def index
   # gon.people = [[1], [2]]
   # gon.people_list = [[1], [2]]
   @people = Person.find_first_degree_for(params[:id])
   gon.people = @people 
  	#gon.people = Person.find_first_degree_for(params[:id])
  	#gon.people_list = Person.select("id, first_name, last_name, ext_birth_year, prefix, suffix, title")
  end
  def test
  	#gon.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
