class ApplicationController < ActionController::Base
  	protect_from_forgery
  	before_filter :expire_hsts, :allow_iframe_requests
  	before_action :store_location
	
	#origin/master
	private

	def store_location
	  # store last url - this is needed for post-login redirect to whatever the user last visited.
	  return unless request.get? 
	  if (request.path != "/sessions/new" &&
	      request.path != "/sessions/destroy" &&
	      request.path != "/sign_in" &&
	      request.path != "/sign_out" &&
	      request.path != "/sign_up" &&
	      request.path != "/users/new" &&
	      !request.xhr?) # don't store ajax calls
	    session[:previous_url] = request.fullpath 
	  end
	end

	def after_sign_in_path_for(resource)
	  session[:previous_url] || root_path
	end

	def expire_hsts
    	response.headers["Strict-Transport-Security"] = 'max-age=0'

  	end
  	def allow_iframe_requests
	  response.headers.delete('X-Frame-Options')
	end
	def current_user
		@current_user ||= User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]  
		if (! @current_user)
			return false
		end
                @current_user
	end
	helper_method :current_user

	def logged_in?
		current_user
	end
	helper_method :logged_in?

	def check_login
		redirect_to sign_in_url, alert: "You need to sign in to view this page." if current_user.nil?
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
	 	flash[:error] = "You do not have access to this page. Please contact the team if you believe you should have access."
	 	redirect_to sign_in_url
	end
end
