class ApplicationController < ActionController::Base
  protect_from_forgery
  
	private
	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	helper_method :current_user

	def logged_in?
		current_user
	end
	helper_method :logged_in?

	def check_login
		redirect_to sign_in_url, alert: "You need to log in to view this page." if current_user.nil?
	end

	def get_data_for_visualization
	    all_people = Person.all
	    # this is a 2d array or many people arrays
	    data_table = []
	    all_people.each do |person|
		    # create a new array for each person
		    person_record = []
		    # add the person's id as the first element of the array
		    person_record.push(person.id)
		    # find all relationships for that person and return the relationship id's, average certainty, and whether the relationship is approved
		    all_rels_for_person = []
		    # all_rels_for_person.push(Relationship.all_for_person(person.id))
		    # person_record.push(all_rels_for_person)
		    # # once the record is complete, add it to all data
		    data_table.push(person_record)
	    end
    	return data_table
    end
    helper_method :get_data_for_visualization

	rescue_from  CanCan::AccessDenied do |exception|
	 	flash[:error] = "Access Denied"
	 	# redirect_to root_url
	end
end
