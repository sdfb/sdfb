class HomeController < ApplicationController
  def index
  	# gon.people = Person.all_approved
  end
  def test
  	gon.people = Person.all_approved
  	gon.test = view_context.asset_path 'data.json'
  end
end
