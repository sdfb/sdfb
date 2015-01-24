class HomeController < ApplicationController
  def index
  	#if (! params[:id].blank?)
  		gon.people = Person.find_first_degree_for(params[:id])
  	# else
  	# 	gon.people = Person.find_first_degree_for(10000473)
  	# end
  	gon.people_list = Person.select("id, first_name, last_name, ext_birth_year, prefix, suffix, title")
  end
  def test
  	#gon.people = Person.find_2_degrees_for_person(params[:person_id])
  end
end
