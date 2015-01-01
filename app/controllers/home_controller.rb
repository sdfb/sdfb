class HomeController < ApplicationController
  def index
  	#gon.people = Person.all_approved
  	gon.people = Person.find_2_degrees_for_person(params[:person_id])
  	gon.people_list = Person.select("id, first_name, last_name, ext_birth_year")
  end
  def test
  	#gon.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
