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

	def expire_hsts
    	response.headers["Strict-Transport-Security"] = 'max-age=0'
  end

	def allow_iframe_requests
	  response.headers.delete('X-Frame-Options')
	end

	def current_user
		token = cookies[:auth_token] || params[:auth_token]
		@current_user ||= User.find_by_auth_token(token) if token
		@current_user 
	end
	helper_method :current_user

	def logged_in?
		current_user
	end
	helper_method :logged_in?

	rescue_from  CanCan::AccessDenied do |exception|
	 	flash[:error] = "You do not have access to this page. Please contact the team if you believe you should have access."
	 	redirect_to sign_in_url
	end
end
