class HomeController < ApplicationController
  def index
  	gon.people = Person.all_approved
  end
  def test
  	gon.people = Person.all_approved

  end
end
